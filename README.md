DevOps for MBIO Cloud - Infrastructure
===

This README will hold an overview of the contents of this repo. This is **WIP**.

# Table of Contents
[[_TOC_]]

# Overview
This repository contains the code for MBIOs Cloud Platform. The code composes of a variety of mechanisms and tools that, together, build a Docker Swarm Based Platform and Backplane for modern Microservice deployments. The platform additionally features a distributed Storage Layer implemented with `Storidge`, spanning across Workers and Managers.

As of now (2020-01-15) the platform consists of 7 nodes (3 Swarm Managers, 2 Swarm Workers and 2 Satellite Nodes fulfilling operational duties) and is deployed to Digital Ocean.

## Access
If not managed by another service (Auth0, LDAP, etc) authentication to all services inside the Platform is defined in variables `admin_user` and `admin_password` in `ansible/playboks/group_vars/all`.

## Managers
Swarm Managers orchestrate the Swarm and all services deployed to it. They build the cluster, manage encryption, networking and service uptime. They also run services.

## Workers
Workers have no special duty. They provide capacity to run services upon.

## Satellites
Satellites are part of the Swarm but not part of the Storage layer. They only have their own local storage. They provide GitLab Runners (with tags `build`), Monitoring, Backup Space and Utility. Satellites being part of the Swarm is needed to operate the Monitoring Layer properly and make use of additional features of the Swarm. Satellites not being part of the Storage layer was a licensing decision. Storidge in its Community Edition only allows up to 5 nodes and 1 TB of provisioned storage.

`Design Decision`: Additionally, Satellites are operating the Monitoring and Backup Layer of the Platform and thus are half in, half out of the operational part of the Cluster so DevOps is able to gain insights and control the Swarm even if anything **inside** the Swarm doesn't operate properly.

## Monitoring
The Platform features a Prometheus/Grafana based Monitoring Layer. The initial decision to use a TIG Stack was discarded during implementation as Prometheus has more batteries included. This enables us to provide insights to almost any part of the Platform out of the box while additionally providing a unified interface for Metrics and Logs.

* Prometheus: https://prometheus.mbiosphere.com
* Grafana: https://grafana.mbiosphere.com

Available Datasources:
* Prometheus
* Loki

Both services have 2 points of configuration. They have custom-built Images the run from in `docker/{prometheus,grafana}`. Running both in Docker really helps scaling but requires custom images to deal with the fact that both services can't be fully configured through environment. Instead of messing with changing configuration in Docker Volumes, it's simpler to build static images of both with the respective Config, Rules and Dashboards baked it. The images are built in GitLab CI (Job-Config in `.gitlab-ci.yml`, Image Config in `docker/{prometheus/grafana}`) with the same versioning enabled that also applies to the `mbiosphere/infrastructure` repository. 

The second point of configuration deals with the Deployment of the services. The `infrastructure` Backplane is handled completely by Ansible. Service- and DNS-Configuration is done in `ansible/playbooks/provision-services.yml` in the respective sections for the service (tags `prometheus` and `grafana`).

Grafana Dashboards can be edited in Grafana directly but need to be exported afterwards and saved to (overwrite existing dashboards) `docker/grafana/config/dashboards/$BOARDNAME` or the changes will be lost after Container Restart. After changing anything to the Docker-related Config, `git commit && git push` to trigger a pipeline that builds the new images.

### Datasources
The Monitoring Layer features a fleet of service containers that simply export/expose metrics that can be scraped by Prometheus.

- cadvisor (Container Metrics)
- dockerd-exporter (Docker/Swarm Metrics)
- node-exporter (Host Metrics)
- cio-exporter (Storidge Metrics)
- promtail (tails /var/log/* on each node)

This can easily be advanced with additional exporters.

### Application Monitoring
Hook your service up to the `monitoring` network (type `overlay`) to access Prometheus, Grafana, etc and make your service accessible for them. You could for example export Prometheus Metrics in your service and scrape them by modifying the Prometheus Custom Image.

### Custom Images
Some services in the Monitoring Layer need special (and mostly file-based) configuration. Since these services run in Docker and manipulating configuration inside running containers is kind of counter-intuitive, custom images will be used.

Any custom image used in this infrastructure is configured in `docker/$service_name` and built by GitLab CI (defined in `.gitlab-ci.yml`). They will be stored in this repository's [Container Registry](https://gitlab.com/mbio/mbiosphere/infrastructure/container_registry).

`Why building custom images?`: another way to deploy Docker containers with dynamic file-based configuration would be to make use of bind-mounts on the hosts. That again would mean to distribute configurations to each node in the cluster which is overhead. Baking static configuration into Docker images makes them versionable and is less prone for errors.

Custom images will be built on each Pipeline run.

### Node Exporter
For Node Exporter to be able to tell us on what node it's running on, we also supply a custom image with special config in the ENTRYPOINT in `docker/node-exporter`.

## Proxy
`Traefik` is used as ingress proxy and manages all incoming connections on port 80 and 443. Traefik also provides the following features:
- SSL Certificate generation with DNS-Validation against Cloudflare
- Loadbalancing for services with multiple instances
- Authentication
- Auto-Forward http -> https
- Security Headers

Traefik can be configured in 2 ways:

### General Config
Traefik's general config is set in `ansible/playbooks/provision-services.yml`, specifically in the `command` section of the `docker_swarm_service` task. By using commandline flags and environment variables, there's no need for file-based config.

### Service Config
Each service/container that needs to be accessed from the outside can be **hooked up** to the Proxy by adding labels to the `deploy:` section of a `docker-compose.yml` (or in Ansible Playbooks) that define how the service will be exposed and what specific configuration it needs from the Proxy (e.g. HSTS, SSL-Forward, PathPrefixes, ...). 

**Example**:

```
labels:
  traefik.enable: "true" # Hooks this service up to the Proxy
  traefik.tags: "proxy" # The tag is needed for Traefik to accept this service as a backend to handle
  traefik.docker.network: "proxy" # The service needs to be part of the `proxy` overlay network that is available swarm-wide
  traefik.port: "8080" # This is the port the services exposes and Traefik will connect to when proxying
  traefik.frontend.rule: "Host:proxy.{{ base_domain }}" # The "Frontend Rule" defines the Hostname (Virtual Host in Apache/NGinx) this service is responsible for
  traefik.backend: "traefik" # This is the name of the backend this service holds in Traefik
  traefik.protocol: "http" # The protocol the container/service expects
  traefik.frontend.headers.SSLRedirect: "true" # Redirect http to https
  traefik.frontend.entryPoints: "http,https" # Possible Entrypoints Traefik accepts connections on for this service
  traefik.backend.loadbalancer.stickiness: "true" # Good for sessions; remember the backend-node used to connections
  traefik.frontend.auth.basic.users: "{{admin_user}}:{{admin_password_hash.stdout}}" # HTTP Basic Auth (user:password)
```

If a service needs to be exposed to the outside, it needs to be part of the `proxy` overlay network for Traefik to be able to reach the containers.

Additionally, Traefik can limit connections to endpoints through IP whitelisting:

`"traefik.frontend.whiteList.sourceRange=172.16.0.0/12"`

## Management
Provisioning, Maintenance and Changes to this infrastructure should typically be done through Ansible/Terraform. At times you might want to have a visual peek into the Infrastructure or quickly want to delete/redeploy a service or use the command line of a container.

Enter [Portainer](https://swarm.mbiosphere). It's an interface to the Swarm and the Storage Layer and a tool to control things happening on the Platform, gaining insights, reading Logs, etc.

* Portainer: https://swarm.mbiosphere

## Consul
The platform features a Consul service (currently consisting of 1 `consul-leader` instance with preparations for a full cluster already in place). Consul provides a KV-backend and is for example a Cluster-Member-Broker for `barbershop`'s rabbitmq instances.

To connect to consul, hook your service up to network `consul` (type `overlay`) and talk to `consul-leader`.

Consul also comes with a webinterface to do basic tasks and gain insights:

* Consul: https://consul.mbiosphere.com

## Versioning
This repository follows `SemVer` and `Conventional Commits` methodologies. This means, each new Push/Merge to `master` will increase the version of this Platform according to SemVer's rules. 

This happens automatically in the Pipelines on each Push/Merge. For this to work correctly, **Contributors** to this repository should follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.2/) Commit-Style.

This is implemented using [go-semrel-gitlab](https://juhani.gitlab.io/go-semrel-gitlab/get-started/) which handles version incrementing, releasing and tagging in GitLab from `.gitlab-ci.yml`.

Releases and Versioning help spotting errors in the infrastructure, pinning working Platform-Releases to a specific release or Commit ID and generally gives a good structure to follow in other projects. Besides that, the Version is not a relevant part of operations and will not cause problems if automatic versioning fails.

### Releases
Each new version of the Platform will also create a new [Tag](https://gitlab.com/mbio/mbiosphere/infrastructure/-/tags) and [Release](https://gitlab.com/mbio/mbiosphere/infrastructure/-/releases) within GitLab. 

## DNS
The infrastructure Code also handles any DNS-related configuration regarding the Platform. This means that URLs, Frontends, etc. that will be provided by the Infrastructure Platform manages their own DNS Records at Cloudflare. Additionally, DNS is used to verify SSL certificates in the Proxy (Traefik).

**IMPORTANT**: if the services deployed to the Platform need additional DNS config, this needs to be done manually at Cloudflare or (which is to be preferred) map the layout of the Microservices deployed to the Platform to Ansible and have the infrastructure also handle service DNS.

## Swagger (WIP)
atm, it works to hook a Swagger Endpoint up to the proxy by adding a label like this:

```
- traefik.swagger.frontend.rule=Host:swagger.${ENVIRONMENT_DOMAIN};PathPrefix:/api/Measurements/apidocs
- traefik.swagger.backend=${DEPLOYMENT}_swagger
```

This example allows access to Swagger for Mirameasurements on https://swagger.staging.mbiosphere.com/api/Measurements/apidocs

The service's swagger-config must reflect the PathPrefix, otherwise you'll get 404s in the Frontend. `tenantservice` is another service with valid Swagger-UI that can be used as a resource.

Currently the Swagger Endpoints are public. You can't execute commands without authenticating against Auth0, but it might be desirable to limit access to BasicAuth or IP Whitelist.

Additionally, for authentication with Auth0, the redirect-url (`audience` in Auth0 lingo) needs to be dynamically obtained from the environment ($ENVIRONMENT_DOMAIN in `.gitlab-ci.yml` for the service) or the OAuth Flow will not work.

## Logging
You can use `Loki` (which comes as a Backplane service) to forward your Container-/Service-Logs to. Simply hook your service up the `monitoring` Overlay Network and add the following `logging` directive to your Stack-Files:

```
logging:
  driver: loki:latest
  options:
    loki-url: "http://logs.mbiosphere.com/loki/api/v1/push"
```

This way your Container Logs will be forwarded to Loki and additionally saved as json-file so `docker logs` continues to work. The Logs can be consumed in [Grafana's Explore](https://grafana.mbiosphere.com/explore?orgId=1&left=%5B%22now-1h%22,%22now%22,%22Loki%22,%7B%22expr%22:%22%7Bservice%3D%5C%22infrastructure_test%5C%22%7D%22%7D,%7B%22mode%22:%22Logs%22%7D,%7B%22ui%22:%5Btrue,true,true,%22none%22%5D%7D%5D) UI.

## Pipelines / Docker in Docker
If you need access to an isolated Docker Environment during your Pipelines, you'll need to add the following service config to your `Job`:

```
services:
    - docker:19.03.5-dind
```

`Docker in Docker` is not loaded automatically on each runner and **should not** be loaded on the top of `.gitlab-ci.yml` files as general Pipeline Service. Not every job makes use of `dind` thus it doesn't make sense to spin up the `dind` container for each job. Enabling the service only for jobs that actually need it saves 30-60s execution time on any job that doesn't load `dind`. This adds up in complex Pipelines or when Pipelines are triggered very often.

# Prerequisites

## GitLab
A dedicated GitLab User (`registry_user`) and Personal Access Token (`gl_token`) is needed to perform versioning duties and login to the GitLab Container Registry during Backplane Service Provisioning. These variables will be used in `ansible/playbooks/provision-services.yml` and the [CI Configuration](https://gitlab.com/mbio/mbiosphere/infrastructure/-/settings/ci_cd) (add a Variable called  `GL_TOKEN` here for the `release` stages to connect to the GitLab API). Additionally, for Runners to register with the Mbio Group, a `runner_token` is needed that will be utilized in `ansible/playbooks/provision-runner.yml`.

These are configured in `ansible/playbooks/group_vars/all`:

* `gl_token`: -
* `registry_url`: registry.gitlab.com
* `registry_user`: "mbio-admin"
* `registry_password`: same as `gl_token`
* `runner_token`: -

`FOLLOW-UP`: it might make sense to put the `GL_TOKEN` Environment Variable into the GitLab Runner Config instead of saving this per repository. This eliminates the need for projects to update Repository-Config to make use of the versioning stages.

### Deploy Tokens
The Pipelines are configured to work with GitLab Deploy Tokens (`$CI_DEPLOY_USER` and `$CI_DEPLOY_TOKEN`) to authorize Docker Nodes against the GitLab Registry. It's important to verify that the Deploy Token has `read_repository` **AND** `read_registry` as a scope. 

The Deploy Token must be set in each Service Repository (e.g. https://gitlab.com/mbio/mbiosphere/mirameasurements/-/settings/repository) in `Settings` > `Repository` > `Deploy Tokens`. If there's an existing Token without `read_registry` scope, simply delete it and create a new one. Typically these tokens are only used in Pipelines by accessing the variables mentioned above so deleting and recreating shouldn't impose problems.

**ATTENTION**: If the Deploy Token does **NOT** have `read_registry` scope, Deployments will fail with the following error:

`No such image: registry.gitlab.com/mbio/mbiosphere/mirameasurements/mirameasurements-celery-worker:2f904b8e`

**ATTENTION**: `Deploy Tokens` are for **DEPLOYMENTS**. They are used to give the Swarm a way to authenticate against the GitLab Registry. For Builds/Pushes to the Registry, this doesn't work, as the `Deploy Token` has only `read_registry` scope and can't write images to the Registry.

For Pushes to the Registry (in `build` and `release` stages) you need the `$CI_JOB_TOKEN`:

```
docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY
```

This Job token is only valid as long as the pipeline runs and thus can't be used for deployments as it's invalidated once the Pipeline finished (which means that during the deploy, when the Docker nodes ask the Registry for the updated image, the Job Token loses validity and Docker can't successfully authenticate against the registry).
## Ansible
```
cd ansible
pip install docker ansible
ansible-galaxy install --ignore-errors -r requirements.yml
```

## Terraform
```
curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip \
    && unzip terraform.zip \
    && rm terraform.zip \
    && chmod +x terraform \
    && mv terraform /usr/local/bin/ \
    && terraform version
```

## Terraform dynamic Inventory for Ansible 
This Go-Tool is needed to convert the *.tfstate file in `terraform/` to a dynamic Ansible inventory. Thus there's no need to provide and maintain a dedicated Ansible inventory file.

```
curl -fsSL "https://github.com/adammck/terraform-inventory/releases/download/v0.9/terraform-inventory_${TERRAFORM_INVENTORY_VERSION}_linux_amd64.zip" -o terraform-inventory.zip \
    && unzip terraform-inventory.zip \
    && rm terraform-inventory.zip \
    && chmod +x terraform-inventory \
    && mv terraform-inventory /usr/local/bin/ \
    && terraform-inventory -version
```

# Misc
##  Ansible Inventory
Ansible works with static and dynamic inventories. For now, we're using dynamic inventories in form of *terraform-inventory* which pulls information from `terraform/terraform.tfstate`.

There's a wrapper script in `ansible/inventory` that removes the need for you to specify locations for tfstate-file, etc while executing playbooks. To list the inventory manually, issue the following command from `ansible/`:

`TF_STATE=../terraform/ ansible-inventory --inventory-file=/usr/local/bin/terraform-inventory --graph` or 
`TF_STATE=../terraform/ ansible-inventory --inventory-file=/usr/local/bin/terraform-inventory --list`

Use this command to invoke the `terraform-inventory` cli directly through the wrapper:

`inventory/terraform -inventory`

**DEPRECATED** (HETZNER): `ansible-inventory -i hcloud.yml --list`

## Garbage Collection
There's a service called `garbage-collector` running on each node that cleans Docker Images, Dangling Volumes, Stopped Containers, etc hourly. It's configured through environment variables in `ansible/playbooks/provision-services.yml`.

# Provisioning
The infrastructure can be provisioned and changed by issueing **one** command. 

1. `cd ansible`
2. `cd ansible && ansible-playbook provision.yml`

This runs all playbooks defined in `ansible/provision.yml` and covers the following steps of work:

1. Spin up the Terraform infrastructure
2. Configure basics for each node (Firewall, Docker, ...)
3. Setup the Swarm
4. Do OS Upgrades (this playbook respects necessary `drain` operations by Docker Swarm and Storidge and executes upgrades sequentially)
5. Setup Storidge Cluster
6. Setup Runners
7. Provision Backplane Services (Traefik, Portainer, etc)

Typically, this is the only command needed to Bootstrap/Maintain the infrastructure during its lifecycle. As one often only needs to change a subset, Playbooks can be executed specifically this way:

`ansible-playbook playbooks/provision-services.yml`

This only provisions the Backplane Services. Same goes for Upgrades, Storidge, etc.

Most tasks are already `tagged` so this is also possible:

`ansible-playbook provision.yml --tags "firewall"

# Access Nodes
From the base directory of this repository you can run `ssh -i .ssh/id_rsa -l root manager-1.nodes.mbiosphere.com` to SSH directly into any of the VMs.

DNS-Management is done in Ansible (tag `dns`).

# Upgrades
**USE WITH CAUTION**

There's a playbook for OS Upgrades in `ansible/playbooks/upgrade-swarm.yml` that sequentially removes nodes from the cluster, applies upgrades and additional maintenance and then adds nodes to the cluster again. This happens **one node at a time** and includes reboots during playbook execution.

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

# Security
The Swarm and Storidge communicate over an internal network. The network topology / subnets aren't statically defined as all the services as well as Ansible can handle dynamic infrastructure very well.

The nodes are currently firewalled. Only ports 443, 80 and 22 are open for ingress from the internet. Internal communication is fully whitelisted. The firewall rules can be changed in `ansible/playbooks/templates/iptables.conf.j2`. Running `ansible-playbook provision.yml --tags="firewall"` from `ansible` directory will update the firewall on all nodes. **USE WITH CAUTION**.

Storidge makes it a requirement to control its cluster nodes through SSH as user `root`, thus it's managing special SSH Keys and the SSH services allows connections from root. This is not ideal and the Storidge Devs are aware and already working on a more secure solution that doesn't require root access via SSH.

## Hardening
The dependencies of this infrastructure includes 2 roles for OS- and SSH-Hardening that can be applied with `ansible-playbook playbooks/harden-node.yml`. I currently strongly advise against it. The roles themselves provide good security defaults but might cause issues with the Storidge cluster. Both (the playbooks and Storidge) heavliy change os-level and ssh-configs that can cause undesired behaviour. It might make sense to deeper define own security needs and apply them manually through Ansible playbooks in accordance with Storidge's requirements.

# Recommendations
- Configure the services' logging-modules to output including timestamps. This eases debugging a lot
- Add a LOG_LEVEL environment config option to all services to enable on-demand debugging
- Have services output start-up info like "version", "status", "db connection", etc. In any scenario, this helps understanding if a service is doing what he should and has all dependencies (like databases, brokers, etc) fulfilled
- Improve Error-Logging (try...catch, better messages) and -Handling
- Add a [healthcheck URL](https://codeblog.dotsandbrackets.com/docker-health-check/) to each http-based service; this helps the swarm to know the state of a task/service and enables advanced monitoring from external apps (datadog, prometheus, etc); for non-http services a local or tcp-based socket works fine, too. The actual healthcheck command the swarm needs to use will be defined in the services stack-file
- Improve docs on service dependencies, needed networks, minimum viable config, etc; for the full-time DevOps to optimally operate the platform, good service-based docs are a must; a good start is to design services around the [12-factor App](https://12factor.net/de/) methodology.

# Future / Missing Additions
- Prometheus Config via CI: https://mrkaran.dev/posts/prometheus-ci/
- Grafana Dashboards visualizing the deployed MBIO Cloud (version, usage, etc)
- Alertmanager
- Finish Backups