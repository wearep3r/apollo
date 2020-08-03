# Get Started

![Apollo. - Platform as a Service](../../wallpaper.jpg)

[[_TOC_]]

## 🚀 Apollo. - Platform as a Service

**Apollo.** is a **Platform as a Service** toolkit. You can use it to build and run applications in a batteries-included and git-versioned environment with the following features:

- **Docker** as container runtime
- **Docker Swarm**, **k8s** or **k3s** as orchestrator
- Automated Distributed Storage with [Storidge](https://storidge.com/) for **Docker Swarm** and [Longhorn](https://rancher.com/docs/k3s/latest/en/storage/) for **k3s**
- Start with 1 Ubuntu 18.04+ node, scale infinitely
- Supports **Windows Workers** in **Docker Swarm** and **k8s** (**ATTENTION**: Limited Support, WIP & alpha!)
- Infrastruture-as-Code modules for AWS, DigitalOcean and HETZNER Cloud
- **Swarm only**: cool backplane (reverse-proxy, auto-ssl, monitoring, auto-backups, dashboards)!
- **Apps**: turn-key GitLab, Minio, GitLab Runner, Rancher, more to come ...

> The goal for **Apollo.** is to get teams up and running fast, with a turn-key platform to accelerate development and innovation

## Feature Matrix

|            | [Swarm](features.md#-docker-swarm) | [k3s](features.md#-k3s) | [k8s](features.md#k8s)  |
|------------|-------|-----|---|
| [Wireguard](features.md#-wireguard)    | ✅    | ✅    | ✅  |
| [Docker](features.md#-docker)    | ✅    | ✅    | ✅  |
| [Distributed Storage](features.md#-distributed-storage)    | ✅    | ✅    | ❌  |
| [Traefik](features.md#-traefik)    | ✅    | ❌    | ❌  |
| [Letsencrypt](features.md#-letsencrypt)    | ✅    | ❌    | ❌  |
| [Monitoring](features.md#-monitoring)    | ✅    | ❌    | ❌  |
| [Logging](features.md#-logging)    | ✅    | ❌    | ❌  |
| [Alerting](features.md#-alerting)    | ✅    | ❌    | ❌  |
| [Portainer](features.md#-portainer)  | ✅    | ❌    | ❌  |
| [Rancher](features.md#-rancher)  | ❌    | ✅    | ✅  |
| [Garbage Collection](features.md#-garbage-collection)  | ✅    | ❌    | ❌  |
| [Prometheus](features.md#-prometheus) | ✅    | ❌    | ❌  |
| [Grafana](features.md#-grafana)    | ✅    | ❌    | ❌  |
| [Backups](features.md#-backups)    | ✅    | ❌    | ❌  |
| [GitLab](features.md#-gitlab)    | ✅    | ❌    | ❌  |
| [Minio](features.md#-minio)    | ✅    | ❌    | ❌  |
| [Statping](features.md#-statping)    | ✅    | ❌    | ❌  |
| [GitLab Runner](features.md#-gitlab-runner)    | ✅    | ❌    | ❌  |

## Typical problems Apollo. solves

1. I need a single-node Docker-Host
2. I need a multi-node Docker-Cluster
3. I need to run Kubernetes
4. I need hyperconverged storage for my applications
5. I need GitLab Runners. Lots of them. Cheap
6. I need a stable backup solution based on S3
7. I need multiple compute environments (staging, production)
8. I need a stable solution to self-host apps
9. I need to spin up ephemeral clusters in CI/CD
10. I need a stable solution for federated monitoring with Prometheus

**Apollo.** is highly scalable (you can start with 1 node and scale up infinitely) and comes with a shared storage layer so you don't have to think about data persistance too much. Your applications' data is available within your entire cluster and regularly backed up - automagically (**Docker Swarm only**).

**Apollo.** comes with a pre-configured set of apps that integrate with each other - such as **GitLab, Sentry, Prometheus, Grafana, Loki, a user backend** and more. You simply enable them and start working!

**Apollo.** aims to accelerate your digital transformation and development process. It helps you to prototype rapidly, but also to deploy to production safely. **Apollo.** gets you up & running quickly, yet provides operational stability even in highly regulated and heterogeneous environments. You can use **Apollo.** as boilerplate for your own platform or manage **Apollo.**-spaces using our CLI or Docker Image.

**Apollo.** is tailored to development teams. Made by seasoned operators, it contains everything a DevOps-enabled team needs to start changing the world.

**Apollo.** runs on every major and minor cloud provider, as well as directly on bare-metal, embedded devices or platforms like Proxmox and VMWare. **Apollo.** comes with integrated support for an [inital set of infrastructure providers](modules/).

**Apollo.** follows an **Infrastructure as Code** design-pattern. The cluster, its state and the apps running on the platform are merely a function applied to the data stored in **Apollo.**'s storage layer. **Apollo.** strictly separates data from application, which means that migrating between clusters is as easy as restoring a backup to a new cluster. Moving a cluster is as easy as providing new compute-resources at a different provider.

**Apollo.** is based on the latest technologies and design patterns. It strives to be fully automated and it greatly reduces the operational overhead in organizations. It's a DevOps platform, doing lots of the Ops work automagically for you. It also manages your Kubernetes cluster!

**Apollo.** comes with a CLI tool that controls all of **Apollo.**'s features. The idea behind this is to better blend the differences between local, production, staging and CI environments and give Developers a transparent way to interact with the applications they develop or use to assist their development (like Sentry).

## Quick-Start

### 1. Get Apollo

Save this **alias** to your `.zshrc` or `.bashrc` file:

```bash
alias apollo="mkdir -p $HOME/.apollo; docker run --rm -it --name apollo -v ${HOME}/.ssh:/root/.ssh -v ${HOME}/.gitconfig:/root/.gitconfig -v ${HOME}/.apollo:/root/.apollo registry.gitlab.com/peter.saarland/zero:latest"
```

### 2. Start Apollo and create your first space

- Start Apollo: `apollo`
- Create your Space: `init`

```bash
~ apollo
                     .__  .__
_____  ______   ____ |  | |  |   ____  
\__  \ \____ \ /  _ \|  | |  |  /  _ \
 / __ \|  |_> >  <_> )  |_|  |_(  <_> )
(____  /   __/ \____/|____/____/\____/
     \/|__|

🚀 .spaces init
[apollo] Initializing new Space
[apollo] Name: apollo-demo
[apollo-demo] Do you want to sync this Space with a remote repository? [y/N]
[apollo-demo] Cloud Provider (generic,hcloud,digitalocean,aws): hcloud
[apollo-demo] HCLOUD Token:
[apollo-demo] Manager instances: 1
[apollo-demo] Worker instances: 0
[apollo-demo] Base domain:
[apollo-demo] Enable LetsEncrypt? [y/N]
                   _ _                 _
  __ _ _ __   ___ | | | ___         __| | ___ _ __ ___   ___  
 / _` | '_ \ / _ \| | |/ _ \ _____ / _` |/ _ \ '_ ` _ \ / _ \
| (_| | |_) | (_) | | | (_) |_____| (_| |  __/ | | | | | (_) |
 \__,_| .__/ \___/|_|_|\___/       \__,_|\___|_| |_| |_|\___/
      |_|

[apollo-demo] 🚀 Space: apollo-demo
[apollo-demo]  ∟ 🌐 Base Domain: 127.0.0.1.xip.io
[apollo-demo]  ∟ 🤖 User: admin
[apollo-demo]  ∟ 🙊 Password: insecure!
[apollo-demo] 🟢 Nodes:
[apollo-demo] 🟢 Backplane: Enabled
[apollo-demo]  ∟ 🟢 Portainer: http://admin:insecure!@portainer.apollo-demo.127.0.0.1.xip.io
[apollo-demo]  ∟ 🟢 Traefik: http://admin:insecure!@proxy.apollo-demo.127.0.0.1.xip.io
[apollo-demo]  ∟ 🟢 Prometheus: http://admin:insecure!@prometheus.apollo-demo.127.0.0.1.xip.io
[apollo-demo]  ∟ 🟢 Grafana: http://grafana.apollo-demo.127.0.0.1.xip.io
[apollo-demo] 🔴 GitLab Runner: Disabled
[apollo-demo] 🔴 Apps: Disabled
```

**ATTENTION:** `Name` must be a URL/DNS-conform string, like `apollo-demo`. This name will be used as a subdomain, so choose carefully.

Your Space is now created. If you're using a cloud provider, certain necessary values **Apollo.** needs to operate will be automatically saved to `nodes.apollo.env` - amongst them `INGRESS_IP`. **Apollo.** generates SSH-Keys for you in `$APOLLO_SPACE_DIR/.ssh` which will be used to connect to the provisioned infrastructure.

In case you're using your own infrastructure, please add the following values (adjusted to your infrastructure) to `infrastructure.apollo.env` manually before proceeding.

```bash
APOLLO_INGRESS_IP=1.2.3.4
APOLLO_NODES_MANAGER=1.2.3.4
APOLLO_NODES_WORKER=
APOLLO_PRIVATE_INTERFACE=eth0
APOLLO_PROVIDER=generic
APOLLO_PUBLIC_INTERFACE=eth0
```

### 3. Ship your Apollo Space

Using `deploy`, you can deploy your Space. Please note that for a successful deployment `INGRESS_IP` needs to have a useful value and needs to be accessible through SSH with the SSH-Keys generated during the init process.

```bash
🚀 apollo-demo.space deploy
```

## Advanced usage

### Architecture

**Apollo.** is organized in **Spaces**. Such a **Space** works as a private environment with a specific configuration and size (it's kind of a **Virtual Private Cloud**). A **Space** is designed to be ephemeral but offers strong capabilities for stateful workloads and long-living clusters.

You can [use GitLab to store and collaborate on **Spaces**](manage-spaces.md).

### Configuration

**Apollo.** is a PaaS toolkit and comes with a bundled IaaS component. The following outlines typical **Space** configurations. For more advanced use-cases, see [Advanced Configuration](advanced-configuration.md).

#### Default configuration

For the following, we assume to handle a **Space** called `apollo-demo`. A Space has sane defaults so it can be started with minimum configuration.

Each Space has a so called `INGRESS_IP` which refers to the node (a VM/Server in the cluster) handling all incoming traffic. Thus, the `INGRESS_IP` will be used for all things DNS and more. It's a vital part of how **Apollo.** works and defaults to `127.0.0.1` or the IP address of the first manager node.

```bash
APOLLO_SPACE=apollo-demo
APOLLO_CONFIG_DIR=~/.apollo
APOLLO_SPACES_DIR=$APOLLO_CONFIG_DIR/.spaces
APOLLO_SPACE_DIR=$APOLLO_SPACES_DIR/$APOLLO_SPACE
APOLLO_PROVIDER=generic
APOLLO_INGRESS_IP=127.0.0.1
APOLLO_BASE_DOMAIN=$APOLLO_INGRESS_IP.xip.io
```

**References**:

- `xip.io`: [wildcard DNS](http://xip.io/)

#### IaaS

Typically, IaaS is confgured in a file called `infrastructure.apollo.env` living in `$APOLLO_SPACE_DIR` (which defaults to `$APOLLO_SPACES_DIR/$APOLLO_SPACE` in the `apollo` container).

The **minimum viable config** to spin up IaaS would be:

```bash
APOLLO_PROVIDER=[hcloud|aws|digitalocean]
PROVIDER_API_KEY=
```

Where `PROVIDER_API_KEY` is actually `HCLOUD_TOKEN` or something similar, depending on your provider.

This would spin up **1 small Ubuntu 18.04 VM** at your cloud provider of choice. It will add 3 files to your **Space**:

- `infrastructure.apollo.plan` is a [Terraform Planfile](https://www.terraform.io/docs/commands/plan.html)
- `infrastructure.apollo.tfstate` is a [Terraform Statefile](https://www.terraform.io/docs/state/index.html)
- `nodes.apollo.env` contains configuration necessary for Apollo to deploy the PaaS component to the VM

#### PaaS

**Apollo.** reads its configuration from the **Environment**. It's designed to run in a container and export configuration found in the **Space** directory to the container's environment. This includes the aforementioned `nodes.apollo.env` that only exists if IaaS has been provisioned successfully or if you created it manually with information about your own hosts.

Assuming we use IaaS to provide infrastructure, the **minimum viable config** to deploy a platform with **Apollo.** would be:

```bash
APOLLO_SPACE=$SPACE_NAME
```

**ATTENTION**: You need to replace `$SPACE_NAME` with the name of the VPC this Apollo-Deployment is part of. It's the name you picked during `init`.

This configuration would deploy the platform with a `$APOLLO_BASE_DOMAIN` of `$APOLLO_INGRESS_IP.xip.io` (`$APOLLO_INGRESS_IP` will be deducted from the Terraform output), Docker Swarm as orchestrator and a few backend services (see [Backplane](backplane.md)). Assuming `APOLLO_INGRESS_IP=213.45.74.3` and `APOLLO_ENVIRONMENT=apollo-demo`, you would have access to the following services:

- Portainer: [http://portainer.apollo-demo.213.45.74.3.xip.io](http://portainer.apollo-demo.213.45.74.3.xip.io)
- Traefik: [http://proxy.apollo-demo.213.45.74.3.xip.io](http://proxy.apollo-demo.213.45.74.3.xip.io)
- Prometheus: [http://prometheus.apollo-demo.213.45.74.3.xip.io](http://prometheus.apollo-demo.213.45.74.3.xip.io)
- Grafana: [http://grafana.apollo-demo.213.45.74.3.xip.io](http://grafana.apollo-demo.213.45.74.3.xip.io)

Username is `admin` and password is `insecure!`.

**Pro-Tipp**: if you want to use your own domain - `beingyou.rocks` - add the following records to your DNS and set `APOLLO_BASE_DOMAIN=beingyou.rocks` in `apollo.env`:

```bash
@ apollo-demo.beingyou.rocks 213.45.74.3
* apollo-demo.beingyou.rocks 213.45.74.3
```

This would give you access to the following endpoints automagically:

- Portainer: [http://portainer.apollo-demo.beingyou.rocks](http://portainer.apollo-demo.beingyou.rocks)
- Traefik: [http://proxy.apollo-demo.beingyou.rocks](http://proxy.apollo-demo.beingyou.rocks)
- Prometheus: [http://prometheus.apollo-demo.beingyou.rocks](http://prometheus.apollo-demo.beingyou.rocks)
- Grafana: [http://grafana.apollo-demo.beingyou.rocks](http://grafana.apollo-demo.beingyou.rocks)