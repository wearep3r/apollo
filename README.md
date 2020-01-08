DevOps for MBIO Cloud
===

This README will hold an overview of the contents of this repo. This is **WIP**.

# Table of Contents
1. [Overview](#example)
2. [Requirements](#example2)
3. [Get Started](#fourth-examplehttpwwwfourthexamplecom)
4. [Ansible](#third-example)
5. [GitLab CI](#fourth-examplehttpwwwfourthexamplecom)
6. [Versioning](#fourth-examplehttpwwwfourthexamplecom)
7. [Changelog](#fourth-examplehttpwwwfourthexamplecom)


# Prerequisites

## Ansible

### Setup
We use the Development Version of Ansible to use the latest HCLOUD modules:

`pip install --user git+https://github.com/ansible/ansible.git@devel`

- https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

## Prerequisites
The Playbooks used to build and maintain this infrastructure have some dependencies that are listed below.

### Local Dependencies
- `sudo pip install hcloud dopy`
- Install Requirements: `ansible-galaxy install -r requirements.yml`
- Ansible Terraform Inventory: `brew install terraform-inventory`

## Overview
To get an idea of what Ansible does and how it works, please (for now) refer to [this link](https://docs.ansible.com/ansible/latest/user_guide/index.html). Over time, most of the functionality used for this project will be highlighted and explained in this README and complementing docs in [this directory](docs/).

Ansible is an SSH-based orchestration software used in terms of **Immutable Infrastructure** and **Infrastructure as Code**. In short words, you define what your infrastructure (hosts, services, configs, etc) should look and behave like - and Ansible will force your will upon the infrastructure.

### Inventory
Ansible works with static and dynamic inventories. For now, we're using dynamic inventories in form of *terraform-inventory* which pulls information from `terraform/terraform.tfstate`.

`TF_STATE=../terraform/ ansible-playbook --inventory-file=/usr/local/bin/terraform-inventory provision.yml`

#### List Inventory
`TF_STATE=terraform/ terraform-inventory -inventory`

**DEPRECATED** (HETZNER): `ansible-inventory -i hcloud.yml --list`


# Provisioning

1. `cd terraform && terraform plan && terraform apply`
2. `cd ansible && TF_STATE=../terraform/ ansible-playbook --inventory-file=/usr/local/bin/terraform-inventory provision.yml`

## First Run
```
cd terraform
terraform plan
terraform apply
sleep 100
cd ../ansible
ansible-playbook provision.yml
```

## Any other Run
Only run each tool when needed. If you don't change underlying infrastructure (VMs, Volumes, etc), there's no need to have Terraform do anything. Ansible can be run at any given time. It's designed to only change things if they need change. Be advised though that changes made manually on a server will be reverted/overwritten by Ansible if it is responsible for it. 

You can limit which parts of the Infrastructure need to be changed by providing `--tags "dns,firewall"` or alike to `ansible-playbook provision.yml` or by simply executing specific playbooks directly (`ansible-playbook playbooks/provision-services.yml`). Both approaches can be combined.

# Access Nodes
From the base directory of this repository you can run `ssh -i .ssh/id_rsa -l root manager-1.nodes.mbiosphere.com` to SSH directly into any of the VMs. 

DNS-Management is done in Ansible (tag `dns`).

# Upgrades
TBD


# Deployment
To make things as automated as possible, Deployment to the swarm should ideally be done through Pipelines. Starting with `mbiosphere/infrastructure:v0.7.0` there are dedicated GitLab Runners running on all Swarm Manager Nodes. They are configured to use the local Docker Socket and provide it to the Containers it runs its jobs in. This means that Jobs running on these Runners can access the Docker Socket of a Swarm Manager directly. These Runners only run when the Job provides a special `deploy` tag and the Runners only accept `docker:*` images. Their only job is to enable automated Deployment to the Swarm while eliminating the need to provide `private SSH keys` as a variable in GitLab. This should ease New Project Setups, Key-Rollovers and Deployment-Complexity a lot.

A typical Deployment Job in GitLab CI could now look as simple as this:

```
deploy:
  stage: deploy
  variables:
    - DEPLOYMENT: infrastructure
  script:
    - docker stack deploy --with-registry-auth --prune -c docker-stack.yml $DEPLOYMENT
  tags:
    - deploy
```

No additional authentication needed. This can be spiced up for complex parts by providing a dedicated deployment image containing all necessary tools (like `mbio-cicibuilder`) and limiting the Runners allowed `image` to this new image in `ansible/playbooks/provision-runner.yml` in the section with tag `deploy`.

# Versioning
- https://juhani.gitlab.io/go-semrel-gitlab/get-started/
- Semantic Versioning
- GitLab Access Token: hxMptRX7KeHsqyxYR3Uf

# Security
The Swarm and Storidge communicate over an internal network. The network topology / subnets aren't statically defined as all the services as well as Ansible can handle dynamic infrastructure very well. 

The nodes are currently firewalled. Only ports 443, 80 and 22 are open for ingress from the internet. Internal communication is fully whitelisted. The firewall rules can be changed in `ansible/playbooks/templates/iptables.conf.j2`. Running `ansible-playbook provision.yml --tags="firewall"` from `ansible` directory will update the firewall on all nodes. **USE WITH CAUTION**.

Storidge makes it a requirement to control its cluster nodes through SSH as user `root`, thus it's managing special SSH Keys and the SSH services allows connections from root. This is not ideal and the Storidge Devs are aware and already working on a more secure solution that doesn't require root access via SSH.

The dependencies of this infrastructure includes 2 roles for OS- and SSH-Hardening that can be applied with `ansible-playbook provision.yml --tags="hardening"`. I currently strongly advise against it. The roles themselves provide good security defaults but might cause issues with the Storidge cluster. Both (the playbooks and Storidge) heavliy change os-level and ssh-configs that can cause undesired behaviour. It might make sense to deeper define own security needs and apply them manually through Ansible playbooks in accordance with Storidge's requirements. 

# Monitoring
Monitoring is finally realized with Prometheus and Grafana. Implementing TIG would have meant more complexity and less automation. Prometheus is highly dynamic and takes most of its configuration from autodiscovery. 

Prometheus and Grafana each have dedicated Web Interfaces:

- [Grafana](https://grafana.mbiosphere.com)
- [Prometheus](https://prometheus.mbiosphere.com)

Both services have 2 points of configuration. They have custom-built Images the run from in `docker/{prometheus/grafana}`. Running both in Docker really helps scaling but requires custom images to deal with the fact that both services can't be fully configured through environment. Instead of messing with changing configuration in Docker Volumes, it's simpler to build static images of both with the respective Config, Rules and Dashboards baked it. The images are built in GitLab CI (Job-Config in `.gitlab-ci.yml`, Image Config in `docker/{prometheus/grafana}`) with the same versioning enabled that also applies to the `mbiosphere/infrastructure` repository. 

The second point of configuration deals with the Deployment of the services. The `infrastructure` Backplane is handled completely by Ansible. Service- and DNS-Configuration is done in `ansible/playbooks/provision-services.yml` in the respective sections for the service (tags `prometheus` and `grafana`).

Grafana Dashboards can be edited in Grafana directly but need to be exported afterwards and saved to (overwrite existing dashboards) `docker/grafana/config/dashboards/$BOARDNAME` or the changes will be lost after Container Restart. After changing anything to the Docker-related Config, `git commit && git push` to trigger a pipeline that builds the new images.

## Node Exporter
For Node Exporter to be able to tell us on what node it's running on, we also supply a custom image with special config in the ENTRYPOINT in `docker/node-exporter`.

# Recommendations
- Configure the services' logging-modules to output including timestamps. This eases debugging a lot
- Add a LOG_LEVEL environment config option to all services to enable on-demand debugging
- Have services output start-up info like "version", "status", "db connection", etc. In any scenario, this helps understanding if a service is doing what he should and has all dependencies (like databases, brokers, etc) fulfilled
- Improve Error-Logging (try...catch, better messages) and -Handling
- Add a [healthcheck URL](https://codeblog.dotsandbrackets.com/docker-health-check/) to each http-based service; this helps the swarm to know the state of a task/service and enables advanced monitoring from external apps (datadog, prometheus, etc); for non-http services a local or tcp-based socket works fine, too. The actual healthcheck command the swarm needs to use will be defined in the services stack-file
- Improve docs on service dependencies, needed networks, minimum viable config, etc; for the full-time DevOps to optimally operate the platform, good service-based docs are a must; a good start is to design services around the [12-factor App](https://12factor.net/de/) methodology.

# Future Additions
- Prometheus Config via CI: https://mrkaran.dev/posts/prometheus-ci/