![apollo - Platform as a Service](../wallpaper.png)

[[_TOC_]]

# Get Started

## apollo - Platform as a Service

**apollo** is a **Platform as a Service** toolkit. You can use it to build and run applications in a batteries-included and git-versioned environment with the following features:

- **Docker** as container runtime
- **Docker Swarm**, **vanilla Kubernetes** or **k3s** as orchestrator
- Scales from 1 to infinite nodes
- Support for stateless & stateful workloads
- Automatically integrated with [Storidge](https://storidge.com/) container IO (minimum cluster size: 4) for **Docker Swarm**
- Can be deployed to any cluster of Ubuntu/Debian nodes
- Supports **Windows Workers** in **Docker Swarm** and **Kubernetes** (currently AWS only)
- Comes with integrations for AWS, DigitalOcean, HETZNER Cloud and VMware
- **Swarm only**: cool backplane (reverse-proxy, auto-ssl, monitoring, auto-backups, dashboards)!
- **Apps**: turn-key GitLab, Minio, GitLab Runner, Rancher, more to come ...
- Management CLI

> The goal for **apollo** is to get teams up and running fast, with a turn-key platform to accelerate development and innovation

**apollo** is highly scalable (you can start with 1 node and scale up infinitely) and comes with a shared storage layer so you don't have to think about data persistance too much. Your applications' data is available within your entire cluster and regularly backed up - automagically (**Docker Swarm only**).

**apollo** comes with a pre-configured set of apps that integrate with each other - such as **GitLab, Sentry, Prometheus, Grafana, Loki, a user backend** and more. You simply enable them and start working!

**apollo** aims to accelerate your digital transformation and development process. It helps you to prototype rapidly, but also to deploy to production safely. **apollo** gets you up & running quickly, yet provides operational stability even in highly regulated and heterogeneous environments. You can use **apollo** as boilerplate for your own platform or manage **apollo**-spaces using our CLI or Docker Image.

**apollo** is tailored to development teams. Made by seasoned operators, it contains everything a DevOps-enabled team needs to start changing the world.

**apollo** runs on every major and minor cloud provider, as well as directly on bare-metal, embedded devices or platforms like Proxmox and VMWare. **apollo** comes with integrated support for an [inital set of infrastructure providers](modules/).

**apollo** follows an **Infrastructure as Code** design-pattern. The cluster, its state and the apps running on the platform are merely a function applied to the data stored in **apollo**'s storage layer. **apollo** strictly separates data from application, which means that migrating between clusters is as easy as restoring a backup to a new cluster. Moving a cluster is as easy as providing new compute-resources at a different provider.

**apollo** is based on the latest technologies and design patterns. It strives to be fully automated and it greatly reduces the operational overhead in organizations. It's a DevOps platform, doing lots of the Ops work automagically for you. It also manages your Kubernetes cluster!

**apollo** comes with a CLI tool that controls all of **apollo**'s features. The idea behind this is to better blend the differences between local, production, staging and CI environments and give Developers a transparent way to interact with the applications they develop or use to assist their development (like Sentry).

## apollo, ship! From buster to cluster in 3 simple steps

### 1. Download apollo-cli

```bash
curl -fsSL -o ~/bin/apollo https://gitlab.com/peter.saarland/apollo-cli/-/jobs/artifacts/master/raw/build/darwin_amd64/apollo?job=compile
chmod +x ~/bin/apollo
apollo version
```

### 2. Create your Apollo Space

```bash
apollo add

# Great! We found a GL_TOKEN and imported
# it to ~/.apollo/apollo.env
#
# apollo will create a **private** repository at
# $APOLLO_REGISTRY_URL/$APOLLO_REGISTRY_GROUP/$APOLLO_SPACE automatically for you
#
# You can disable this by setting
# APOLLO_REPOSITORY_AUTO_CREATE=0
# in ~/.apollo/apollo.env
#

### Create your Apollo Space ###
Name: draconic-envelope-galore ($SPACE_NAME)
Use Cloud Provider?: [Y/n]
Cloud Provider: [HCLOUD, digitalocean, aws]
Cloud Provider Authentication: 
Custom Domain?: [y/N]
Enter Base Domain: [beingyou.rocks]

# Success! New VPC designed. Now go ship it!
```

**ATTENTION:** `Name` must be a URL/DNS-conform string, like `apollo-test-1`. This name will be used as a subdomain, so choose carefully.

### 3. Ship your Apollo Space

```bash
apollo ship $SPACE_NAME
```

## Advanced usage

### Architecture

**apollo** is organized in **Spaces**. Such a **Space** works as a private environment with a specific configuration and size (**Virtual Private Cloud**). A **Space** is designed to be ephemeral but offers strong capabilities for stateful workloads and long-living clusters.

**Spaces** are managed with `apollo-cli`. You can [use GitLab to store and collaborate on **Spaces**](manage-spaces.md).

### Configuration

**apollo** is a PaaS toolkit and comes with a bundled IaaS component. The following outlines typical **Space** configurations. For more advanced use-cases, see [Advanced Configuration](advanced-configuration.md).

#### IaaS

Typically, IaaS is confgured in a file called `infrastructure.apollo.env` living in `$APOLLO_ENVIRONMENT_DIR` (which defaults to `/root/.apollo/.environments/apollo/` in the `apollo` container).

The **minimum viable config** to spin up IaaS would be:

```bash
APOLLO_PROVIDER=[hcloud|aws|digitalocean]
PROVIDER_API_KEY=
```

This would spin up **1 small Ubuntu 18.04 VM** at your cloud provider of choice. It will add 3 files to your **VPC** config:

- `apollo.plan` is a [Terraform Planfile](https://www.terraform.io/docs/commands/plan.html)
- `apollo.tfstate` is a [Terraform Statefile](https://www.terraform.io/docs/state/index.html)
- `nodes.apollo.env` contains configuration necessary for Zero to deploy the PaaS component to the VM

#### PaaS

**apollo** reads its configuration from the **Environment**. It's designed to run in a container and export configuration found in the **Space** directory to the container's environment. This includes the aforementioned `nodes.apollo.env` that only exists if IaaS has been provisioned successfully.

Assuming we use IaaS to provide infrastructure, the **minimum viable config** to deploy a platform with **apollo** would be:

```bash
APOLLO_ENVIRONMENT=$SPACE_NAME
```

**ATTENTION**: You need to replace `$SPACE_NAME` with the name of the VPC this Apollo-Deployment is part of. It's the name you picked during `apollo add`.

This configuration would deploy the platform with a `$APOLLO_BASE_DOMAIN` of `$APOLLO_INGRESS_IP.xip.io` (`$APOLLO_INGRESS_IP` will be provided by IaaS), Docker Swarm as orchestrator and a few backend services. Assuming `APOLLO_INGRESS_IP=213.45.74.3` and `APOLLO_ENVIRONMENT=draconic-envelope-galore`, you would have access to the following services:

- Portainer: http://portainer.draconic-envelope-galore.213.45.74.3.xip.io
- Traefik: http://proxy.draconic-envelope-galore.213.45.74.3.xip.io
- Prometheus: http://prometheus.draconic-envelope-galore.213.45.74.3.xip.io
- Grafana: http://grafana.draconic-envelope-galore.213.45.74.3.xip.io

Username is `admin` and password is `insecure!`.

**Pro-Tipp**: if you want to use your own domain - beingyou.rocks - add the following records to your DNS and set `APOLLO_BASE_DOMAIN=beingyou.rocks` in `apollo.env`:

```bash
@ draconic-envelope-galore.beingyou.rocks 213.45.74.3
* draconic-envelope-galore.beingyou.rocks 213.45.74.3
```

This would give you access to the following endpoints automagically:

- Portainer: http://portainer.draconic-envelope-galore.beingyou.rocks
- Traefik: http://proxy.draconic-envelope-galore.beingyou.rocks
- Prometheus: http://prometheus.draconic-envelope-galore.beingyou.rocks
- Grafana: http://grafana.draconic-envelope-galore.beingyou.rocks