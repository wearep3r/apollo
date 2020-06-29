
[[_TOC_]]

# Get Started

## Appollo - Turn-Key Application Platform

**Appollo** is an application platform. You can use it to build and run applications in a batteries-included and git-versioned environment with the following features:

- **Docker** as container runtime
- **Docker Swarm**, **vanilla Kubernetes** or **k3s** as orchestrator
- Scales from 1 to infinite nodes
- Support for stateless & stateful workloads
- Automatically integrated with [Storidge](https://storidge.com/) container IO (minimum cluster size: 4)
- Can be deployed to any cluster of Ubuntu/Debian nodes
- Supports **Windows Workers** in **Docker Swarm** and **Kubernetes** (currently AWS only)
- Comes with integrations for AWS, DigitalOcean, HETZNER Cloud and VMware
- **Swarm only**: cool backplane (reverse-proxy, auto-ssl, monitoring, auto-backups, dashboards)!
- **Apps**: turn-key GitLab, Minio, GitLab Runner, Rancher, more to come ...
- CLI integration (TBD)

> The goal for Appollo is to get teams up and running fast, with a set of turn-key services to accelerate development and infrastructure they do not need to worry about

Appollo is highly scalable (you can start with 1 node and scale up infinitely) and comes with a shared storage layer so you don't have to think about data persistance too much. Your applications' data is available within your entire cluster and regularly backed up - automagically (**Docker Swarm only**).

Appollo comes with a pre-configured set of apps that integrate beautifully with each other - such as **GitLab, Sentry, Prometheus, Grafana, Loki, a user backend** and more. You simply enable them and start working!

Appollo aims to accelerate your digital transformation and development process. It helps you to prototype rapidly, but also to deploy to production safely. Appollo gets you going quickly, yet provides operational stability even in highly regulated and heterogeneous environments. You can use Appollo as boilerplate for your own platform or manage Appollo-Clusters using our CLI or Docker Image.

Appollo is tailored to development teams. Made by seasoned operators, it contains everything a DevOps-enabled team needs to start changing the world, without worrying about Ops too much.

Appollo runs on every major and minor cloud provider, as well as directly on bare-metal, embedded devices or platforms like Proxmox and VMWare. Integrated support for an inital set of cloud providers is delivered by [Dash1](https://gitlab.com/peter.saarland/dash1).

Appollo follows an **Infrastructure as Code** design-pattern. The cluster, its state and the apps running on the platform are merely a function applied to the data stored in Appollo's storage layer. Zero strictly separates data from application, which means that migrating between clusters is as easy as restoring a backup to a new cluster. Moving a cluster is as easy as providing new compute-resources at a different provider.

Appollo is based on the latest technologies and design patterns. It strives to be fully automated. Zero greatly reduces the operational overhead in organizations. It's a DevOps platform, doing lots of the Ops work automagically for you. It also manages your Kubernetes cluster!

Appollo's best friend is **if0**, a CLI tool that controls all of Appollo's features. The idea behind Appollo and if0 is to blend the differences between local, production, staging and CI environments and give Developers a transparent way to interact with the applications they develop or use to assist their development (like Sentry).

## Appollo, Ship! From buster to cluster in 3 simple steps

### 1. Download if0

```bash
curl -fsSL -o ~/bin/if0 https://gitlab.com/peter.saarland/if0/-/jobs/artifacts/master/raw/build/darwin_amd64/if0?job=compile
chmod +x ~/bin/if0
if0 version
```

### 2. Create your Appollo VPC

```bash
if0 add

# Great! We found a GL_TOKEN and imported
# it to ~/.if0/if0.env
#
# if0 will create a **private** repository at
# $IF0_REGISTRY_URL/$IF0_REGISTRY_GROUP/$VPC_NAME automatically for you
#
# You can disable this by setting
# IF0_REPOSITORY_AUTO_CREATE=0
# in ~/.if0/if0.env
#

### Create your Appollo VPC ###
Name: draconic-envelope-galore
Use Cloud Provider?: [Y/n]
Cloud Provider: [HCLOUD, digitalocean, aws]
Cloud Provider Authentication: 
Custom Domain?: [y/N]
Enter Base Domain: [beingyou.rocks]

# Success! New VPC designed. Now go ship it!
```

**ATTENTION:** `Name` must be a URL/DNS-conform string, like `zero-test-1`. This name will be used as a subdomain, so choose carefully.

### 3. Ship your Appollo VPC

```bash
if0 ship $VPC_NAME
```

## Advanced usage

### Architecture

Appollo is organized in **VPC**s aka **Virtual Private Clouds**. Such a **VPC** works as a private environment with a specific configuration and size. A VPC is designed to be ephemeral but offers strong capabilities for stateful workloads and long-living clusters.

**VPCs** are managed with `if0`. You can [use GitLab to store and collaborate on **VPCs**](manage-vpcs.md).

### Configuration

Appollo is a PaaS component. It is accompanied by an IaaS component - Dash1. Together, they form a **VPC**. The following outlines typical **VPC** configurations. For more advanced use-cases, see [Advanced Configuration](advanced-configuration.md).

#### IaaS - Dash1

**Dash1**, just like Appollo, reads configuration from the **Environment**. Dash1 is designed to run in a container and exports the content of any file matching the following expression to the running container's environment on container start: `/root/.if0/.environments/zero/*.env`

Typically, Dash1 expects its configuration in a file called `dash1.env` living in `$IF0_ENVIRONMENT_DIR` (which defaults to `/root/.if0/.environments/zero/`).

The **minimum viable config** to spin up infrastructure as code with Dash1 would be:

```bash
DASH1_MODULE=[hcloud|aws|digitalocean]
PROVIDER_API_KEY=
```

This would spin up **1 small Ubuntu 18.04 VM** at your cloud provider of choice. It will add 3 files to your **VPC** config:

- `dash1.plan` is a [Terraform Planfile](https://www.terraform.io/docs/commands/plan.html)
- `dash1.tfstate` is a [Terraform Statefile](https://www.terraform.io/docs/state/index.html)
- `dash1-zero.env` contains configuration necessary for Zero to deploy the PaaS component to the VM

#### PaaS - Appollo

**Appollo** reads its configuration from the **Environment**. Like Dash1, it's designed to run in a container and export configuration found in the **VPC** directory to the container's environment. This includes the aforementioned `dash1-zero.env` that only exists if Dash1 infrastructure has been provisioned successfully.

Assuming we use Dash1 to provide infrastructure, the **minimum viable config** to deploy a platform with Zero would be:

```bash
IF0_ENVIRONMENT=$VPC_NAME
```

**ATTENTION**: You need to replace `$VPC_NAME` with the name of the VPC this Appollo-Deployment is part of. It's the name you picked during `if0 init`.

This configuration would deploy the platform with a `$ZERO_BASE_DOMAIN` of `$ZERO_INGRESS_IP.xip.io` (`$ZERO_INGRESS_IP` will be provided by Dash1), Docker Swarm as orchestrator and a few backend services. Assuming `ZERO_INGRESS_IP=213.45.74.3` and `IF0_ENVIRONMENT=draconic-envelope-galore`, you would have access to the following services:

- Portainer: http://portainer.draconic-envelope-galore.213.45.74.3.xip.io
- Traefik: http://proxy.draconic-envelope-galore.213.45.74.3.xip.io
- Prometheus: http://prometheus.draconic-envelope-galore.213.45.74.3.xip.io
- Grafana: http://grafana.draconic-envelope-galore.213.45.74.3.xip.io

Username is `admin` and password is `insecure!`.

**Pro-Tipp**: if you want to use your own domain - beingyou.rocks - add the following records to your DNS and set `ZERO_BASE_DOMAIN=beingyou.rocks` in `zero.env`:

```bash
@ draconic-envelope-galore.beingyou.rocks 213.45.74.3
* draconic-envelope-galore.beingyou.rocks 213.45.74.3
```

This would give you access to the following endpoints automagically:

- Portainer: http://portainer.draconic-envelope-galore.beingyou.rocks
- Traefik: http://proxy.draconic-envelope-galore.beingyou.rocks
- Prometheus: http://prometheus.draconic-envelope-galore.beingyou.rocks
- Grafana: http://grafana.draconic-envelope-galore.beingyou.rocks