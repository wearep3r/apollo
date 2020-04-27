zero - The App Platform
===

[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release) [![pipeline status](https://gitlab.com/peter.saarland/zero/badges/master/pipeline.svg)](https://gitlab.com/peter.saarland/zero/-/commits/master)

Maintained by [Peter.SAARLAND | DevOps Consultants](https://www.peter.saarland) - Helping companies to develop software with starup speed and enterprise quality.

This README will hold an overview of the contents of this repo. This is **WIP**.

# Table of Contents
[[_TOC_]]

# Overview
This repository contains the code for the **zero** DevOps Platform. The code composes of a variety of mechanisms and tools that, together, build a Docker Swarm or Kubernetes Based Platform and Backplane for modern App Deployments. The platform additionally features a distributed Storage Layer implemented with **Storidge**`**, spanning across Workers and Managers.

**The goal for zero is to get teams up and running fast, with a set of services to help them and infrastructure they do not need to worry about.**

Zero is a **Platform for Apps**. It runs on **Docker Swarm** or **Kubernetes**. It's controlled by **if0 -** the CLI to tool them all.

Zero is highly scalable (you can start with 1 node and scale up infinitely) and comes with a shared storage layer so you don't have to think about that. Your applications' data is available within your entire cluster and regularly backed up - automagically.

Zero comes with a pre-configured set of Apps that integrate beautifully with each other - such as **GitLab, Sentry, Prometheus, Grafana, Loki, a User Backend** and more. You simply enable them and start working!

Zero aims to accelerate your Digital Transformation and Development Process. It helps you to prototype rapidly, but also to deploy to production safely. Zero gets you going quickly, yet provides operational stability even in highly regulated and heterogeneous environments.

Zero is tailored to Development teams. Made by seasoned Operators, it contains everything a DevOps-enabled team needs to start changing the world, without worrying about Ops too much.

Zero runs on every major and minor Cloud Provider, as well as directly on bare-metal, Embedded Devices or Platforms like Proxmox and VMWare. 

Zero is follows an **Infrastructure as Code** design-pattern. The Cluster, its state and the Apps running on the platform are merely a function applied to the data stored in Zero's storage layer. Zero strictly separates Data from Application, which means that migrating between Clusters is as easy as restoring a Backup to a new Cluster. Moving a Cluster is as easy as providing new Compute-Resources at a different Provider.

Zero is based on the latest technologies and design patterns. It strives to be fully automated. Zero greatly reduces the operational Overhead in organizations. It's a DevOps Platform, doing lots of the Ops work automagically for you. It also manages your Kubernetes Cluster!

Zero's best friend is **if0**, a CLI tool that controls all of Zero's features. The idea behind Zero and if0 is to blend the differences between local, production, staging and CI environments and give Developers a transparent way to interact with the Applications they develop or use to assist their development (like Sentry).

This is an example of what the deployment of and work with **zero** looks like:

![zero Overview](./docs/zero.jpg)

## Backplane Services

**Portainer** is intended to become the single management UI for applications and services operated on **zero**. In the future more [app templates](https://www.portainer.io/overview/) will be provided here.

**Traefik** acts as the single proxy to manage connections between all services on **zero**, backplane AND custom. Furthermore it provides [load balancing capabilities](https://docs.traefik.io/routing/overview/) to the platform. From the Traefik dashboard (endpoint `proxy.<hostname>`) you can see all frontend and backend services with their addresses within the cluster/swarm.

**Grafana** is single entry point for [troubleshooting, logs access and alerts](https://grafana.com/grafana/). The logs of all nodes are stored on the node where they stem from and consolidated on manager nodes for access through Grafana. **Loki** is [used for this](https://github.com/grafana/loki). Prometheus provides alerts and metrics on node level and consolidates them as well. Grafana accesses data from all these sources to provide a consolidated view on the health of the cluster/swarm and the services and applications running on it. Predefined dashboards, e.g. on data provided by Loki are available after installation. **Unsee** is used for a [dedicated view on alerts](https://github.com/cloudflare/unsee) and integrates with the [Prometheus Alertmanager](https://prometheus.io/docs/alerting/alertmanager/). <br/>**zero** comes with a set of predefined alerts around the area of hardware thresholds and such, as part of the **Prometheus** [configuration](https://gitlab.com/peter.saarland/zero/-/tree/master/docker/prometheus/config).

More services used behind the curtains are:
- [node_exporter](https://github.com/prometheus/node_exporter) to access hardware metrics on each node
- [ansible-role-ntp](https://github.com/geerlingguy/ansible-role-ntp) for node time synchronization

## Additional Services

- **Let's Encrypt** is used to issue certificates for zero services via DNS validation through Traefik
- **GitLab Runner** 
- **Nextcloud**

## Network configuration

To allow connections to services from outside the **zero** environment, the docker firewall is configured to allow traffic on standard ports [during node provisioning](https://gitlab.com/peter.saarland/zero/-/blob/master/playbooks/templates/iptables.conf.j2).

## Storidge

[Storidge](https://storidge.com/product/) uses the concept of [volumes](https://guide.storidge.com/getting_started/volumes.html) to abstract persistent storage (block-, file- or objectstorage) from applications. Volumes are mounted on OS level and can then be used by Docker containers and services as [Docker volumes](https://guide.storidge.com/getting_started/docker_volumes.html).

Storidge allows high-availability setups, live-changes to the cluster (e.g. add/remove node), etc. So basically, Storidge provides the same flexibility to storage like Docker Swarm/Kubernetes do to computing for applications on top of **zero**.

# Roadmap

Work in progress by @derfabianpeter.

Open topics are:
- **Backup & restore** with an own versioning mechanism of the snapshots to be stored on storages like AWS S3
- **DNS**: Currently docker swarm does internal DNS resolution for all nodes, which does not support access to hosts outside of the swarm. Prometheus and other services in the backplane can cope with multiple IPs being resolved for a single hostname. However this is not depictable in the host OSs `/etc/hosts` file. Hence **zero** needs a more sophisticated DNS solution.
- Deployment on **Windows** hosts
- Change from **ansible** templates used to setup infrastructure, backplane and such to **compose** files
- A dedicated CLI to make interacting with **zero** easier
- Deployment an **ARM** (Raspberry)
- Automatic detection of interface names other than `eth1`

# Prerequisites

Currently, the Platform is designed to be run on Digitalocean, but any setup matching the following prerequisites should be able to operate **zero**:

## Minimum Requirements
- 1+ Ubuntu 18.04/Debian 10 Servers
- 4GM RAM
- 1 CPUs
- 20GB Local Disk

## Requirements for Storidge
- 4+ Ubuntu 18.04 Servers (with Kernel **4.15.0-74-generic**)
- 16GB RAM
- 4 CPUs
- 100GB Local Disk
- 3x 50GB+ raw Block Devices (unformatted disks, e.g. Block-Volumes from DigitalOcean)

# Configuration
**zero** accepts all configuration through Environment Variables. The available configuration options can be found in `.env.example`.

# Authentication
If not managed by another service (Auth0, LDAP, etc) authentication to all services inside the Platform is defined in variables `ADMIN_USER` and `ADMIN_PASSWORD`.

# Running it
Here's what you have to do to spin up **zero**:

⚠️ This setup assumes using terraform against an existing cluster with a certain configuration. To run **zero** against a single Ubuntu VM, see [](#on-digitalocean)

1. Create the `.env` file with your settings (Hint: copy from `.env.example `)
2. Make sure **Docker** is installed
3. Have 1+ Servers ready with your SSH public key
4. Run **zero**: `docker run -v "${PWD}/.env:/infrastructure/.env" -v "${HOME}/.ssh:/.ssh" registry.gitlab.com/peter.saarland/zero:latest ./if0 provision`

## Windows
- https://github.com/PowerShell/Win32-OpenSSH/wiki/Install-Win32-OpenSSH
- https://computingforgeeks.com/install-and-configure-openssh-server-on-windows-server/

```
# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Both of these should return the following output:

Start-Service sshd
# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'
# Confirm the Firewall rule is configured. It should be created automatically by setup. 
Get-NetFirewallRule -Name *ssh*
# There should be a firewall rule named "OpenSSH-Server-In-TCP", which should be enabled
# If the firewall does not exist, create one
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

```

## Vagrant
To quickly run **zero** on a local machine, you can use vagrant:

`vagrant up`

To (re-)provision **zero**:

`vagrant provision`

See the associated [Vagrantfile](Vagrantfile) for additional information.

## On DigitalOcean

This is intended to be the minimal step required to run zero on a single Ubuntu VM meeting the [](#minimum-requirements), running on DigitalOcean.

### Prerequisites 

- Install terraform on your local machine
- Run `terraform init` once in the project root
- Install and run docker on your local machine
- Check the [configuration](#configuration) and [authentication](#authentication) sections above.

### Steps

1. Create the `.env` file with your settings (Hint: copy from `.env.example `)
2. Set
   - `DIGITALOCEAN_ENABLED=1`
   - `DIGITALOCEAN_AUTH_TOKEN` to your access token
   - `SSH_PRIVATE_KEY_FILE` to an existing ssh key or a non-existing one if you want to create a new one, e.g. `~/.ssh/id_rsa_zero`
   - `REMOTE_USER=root` Deployment via `root` is required currently, due to assumptions other projects used by **zero** made
3. (Optional) Run `make ssh-gen` to generate the new ssh key if its not existing yet
4. Run `make setup`, this will create the Ubuntu droplet in your default project
5. Run `make show` and copy the `ipv4_address` of the newly created VM
6. Paste the address to the following variables in the `.env` file: `INGRESS_IP=<ipv4>`, `ZERO_NODES=<ipv4>`, `BASE_DOMAIN=<ipv4>.xip.io`
7. Run `make deploy` to deploy zero with all backplane services to the VM

    ℹ️ This command can be re-run over and over when making changes to the infrastructure, services or doing troubleshooting.

8. (Optional) Run `make teardown` to stop and delete the VM.

### Endpoints

- Portainer: `portainer.<ipv4address>.xip.io`
- Grafana: `grafana.<ipv4address>.xip.io`
- Traefik: `proxy.<ipv4address>.xip.io`
- Unsee: `alerts.<ipv4address>.xip.io`

### Troubleshooting

**The deployment complains about the network interface `eth1` not being available**

Ubuntu can choose different names for its network interfaces and **zero** currently cannot cope with that. To workaround that issue:

- ssh into VM via `make ssh` and run `ifconfig` to find the correct name of the adapter (check for the IP)
- set the `PUBLIC_INTERFACE` and `PRIVATE_INTERFACE` variables in `.env` to the correct name

**I've created my infrastructure with `docker-machine` and now the `Checking on Docker Installation` step fails**

`docker-machine` already installs a newer version of Docker on the VM compared to the one **zero** uses. Unfortunately ansible is not capable allowing downgrades during installation (see [this issue](https://github.com/ansible/ansible/issues/29451)).

## On IBM

To run **zero** on IBM, follow these steps:
- refer to the `terraform` template in `./terraform/ibm`. This requires the [IBM terraform provider](https://github.com/IBM-Cloud/terraform-provider-ibm)
- Set `IBM_ENABLED=1`, `IBM_ACCESS_KEY=<your key>` and `IBM_RESOURCE_GROUP_ID=<your resource group id>` in the `.env` file
- Ensure that you have a SSH key created (see [DigitalOcean](#on-digitalocean) section) 
- Run `make ibm-login` to log in to the IBM CLI
- Run `make ibm-rg-create` to create the target resource group (if not existing)
- Run `make ibm-setup` to setup the VM and dependencies
- Run `make deploy` (similar to digitalocean)

Configuration:
- Update the instance size to your needs, available options [can be found here](https://www.ibm.com/cloud/vpc/pricing)

## On AWS

For AWS, there is a terraform template located in `terraform/aws` setting up a single EC2 instance with a public elastic IP address

To run **zero** on IBM, follow these steps
1. Ensure `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_SESSION_TOKEN` are properly populated
2. Ensure you've setup your local ssh key (see above) using the `Makefile`
3. Run `make aws-setup`
4. Copy the public IP address and paste it into you `.env` file (see above)
5. Run `make deploy`

## HOW-TOs

### How to test a local change?

1. Save all files
2. Run `make build` to build a new docker image of zero with your local changes
3. Run `make deploy-local` to deploy that local image 

### How to find out why `dockerd` is not starting on an Ubuntu host?

1. SSH into the host via `make ssh` (for single node configurations)
2. Run `journalctl -eu docker`
