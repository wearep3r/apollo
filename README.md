# 🚀 apollo - a DevOps platform

**apollo** helps you to get from idea to production fast and safe - you'll be up & running quickly with a cloud-native tech-stack and great operational stability. It's made for developers and operators alike.

Use this repository as a boilerplate for your own platform or manage your [apollo spaces](#-) using our batteries-included [Docker image](#-).

[!["Maintained"](https://img.shields.io/maintenance/yes/2020?color=green)](https://github.com/wearep3r/apollo)
[!["Version"](https://img.shields.io/github/v/tag/wearep3r/apollo?label=version)](https://github.com/wearep3r/apollo)
[!["License"](https://img.shields.io/github/license/wearep3r/apollo)](https://github.com/wearep3r/apollo)
[!["p3r. Slack"](https://img.shields.io/badge/slack-@wearep3r/general-purple.svg?logo=slack&label=Slack)](https://join.slack.com/t/wearep3r/shared_invite/zt-d9ao21f9-pb70o46~82P~gxDTNy_JWw)
[!["GitHub Stars"](https://img.shields.io/github/stars/wearep3r/apollo?logo=github)](https://github.com/wearep3r/apollo)
[!["Docker Hub Downloads"](https://img.shields.io/docker/pulls/wearep3r/apollo?label=Downloads&logo=docker)](https://hub.docker.com/r/wearep3r/apollo)
[!["Docker Image Size"](https://img.shields.io/docker/image-size/wearep3r/apollo?logo=docker&label=Image)](https://hub.docker.com/r/wearep3r/apollo)

## What's inside

apollo manages the full **life-cycle of a container platform**:

- creation of infrastructure
- provisioning of configuration
- monitoring of resources
- logging of events
- alerting of incidents
- visualization of metrics
- management of operations
- deployment of applications
- elemination of waste

We call those platforms **spaces**.

### Features

- Distributed container platform (**Docker Swarm** or **Kubernetes**)
- Git-versioned configuration method tailored to CI/CD 
- Automated infrastructure (currently only **DigitalOcean** and **HETZNER Cloud** supported)
- Ready-to-rock, auto-ssl ingress proxy by **Traefik**
- Cluster-wide metrics & logs with **Victoria Metrics** and **Grafana Loki**
- Secure networking through **Wireguard**
- Beautiful dashboards thanks to **Grafana**
- Configured almost entirely by **environment variables**
- Distributed storage (**Storidge**, **NFS** or **Longhorn**)
- **Single-node clusters are possible** and can be scaled up
- Integrated with [GitLab](https://gitlab.com) (CI/CD, registry, environments, metrics, kubernetes)
- Support for configuration encryption, auditing and Continuous Delivery

## What you can do with it

1. Single-node Docker-Hosts for [Remote Development with VSCode](https://code.visualstudio.com/docs/remote/remote-overview)
2. Multi-node Docker-Clusters for [SaaS apps](https://dockerswarm.rocks/)
3. Single- or Multi-Node [Kubernetes clusters](https://k3s.io/)
4. Auto-Managed [distributed storage](https://storidge.com/) for stateful applications
5. Auto-Managed [GitLab Runners](https://docs.gitlab.com/runner/) on trusted hardware
6. Stable and secure [S3 storage](https://min.io/)
7. Multiple [environments](https://www.digitalocean.com/community/tutorials/an-introduction-to-ci-cd-best-practices) (staging, production)
8. [GitLab Review Apps](https://docs.gitlab.com/ee/ci/review_apps/)
9. [Self-hosting](https://geek-cookbook.funkypenguin.co.nz/) arbitrary apps
10. One-shot ephemeral clusters for [testing in CI/CD](https://dev.to/katiatalhi/provision-ephemeral-kubernetes-clusters-on-aws-eks-using-terraform-and-gitlab-ci-cd-3f74)
11. [Federated monitoring](https://banzaicloud.com/blog/prometheus-federation/) with Prometheus and Grafana
12. [Hybrid clusters](https://www.packet.com/resources/guides/crosscloud-vpn-with-wireguard/) (thanks to Wireguard)

## How it works

1. You supply [minimum configuration](#-getting-started) to create a **space**
2. apollo creates infrastructure if needed
3. apollo configures the machines and sets up your container platform
4. You check out the auto-generated README to know the next steps

Check the [Getting Started](#-getting-started) section to start your journey with apollo.

## Philosophy

These are the design principles we base our work on apollo on. It's heavily inspired by DevOps and Clean Code practices and the works and arts of Martin Fowler who brought us immutable infrastructure.

- Every **space**, including development, SHOULD be versioned in a repository
- There is ONE workflow for installation and deployment that applies to all spaces
- No manual actions on the platform - everything must be code
- Every change to infrastructure SHOULD be code-reviewed to:
  - avoid mistakes
  - make other (including non-DevOps) team members able to learn
  - make sure everything stays portable and immutable
- Everyone SHOULD be able to:
  - create their development environment in a minute with minimum effort
  - reproduce a production-like environment
  - understand the whole infrastructure
  - propose modifications to the infrastructure, while being able to test them
- apollo SHOULD be a boilerplate and a framework: modify it to fulfill your needs!
- The companion CLI is written in Bash so it is easy to understand what a command does, and it is easy to modify command behaviors or to add new ones

apollo is tailored to development teams. It's made by seasoned operators and contains everything a DevOps-enabled team needs to start changing the world.

apollo runs on every major and minor cloud provider, as well as directly on bare-metal. IoT devices or platforms like Proxmox and VMWare are currently on the roadmap.

apollo is based on the latest technologies and design patterns. We're working hard to make it fully automated but it already reduces lots of the operational overhead in organizations. It's a DevOps platform, doing ops work automagically for you, so you can do developer magic on top of it.

## Knowledge prerequisites

If you want to build upon this repository, you'll need to be very proficient with the following tools:

- Ansible
- Terraform
- Bash
- Docker
- Python
- Docker Swarm
- Kubernetes

If you just want to use apollo to manage your container platforms, you just need to know:

- Docker

## Technical prerequisites

- Local machine: Docker
- Remote machines: Ubuntu 18.04

## Getting started

The simplest way to use **apollo** is to run our [Docker Image](https://hub.docker.com/r/wearep3r/apollo/tags).

### Prerequisites

You need to install [Docker](https://docs.docker.com/get-docker/). Once done, create a directory that holds apollo's configuration and the [spaces](#-) apollo manages:

```bash
mkdir -p $HOME/.apollo
```

### Installing apollo

Download apollo's Docker Image from the Docker Hub:

```bash
docker pull wearep3r/apollo
```

### Running apollo

Run apollo's Docker Image (**apollo** needs access to a few local directories to work properly):

```bash
docker run --rm -it \
  --name apollo \
  -v ${HOME}/.ssh:/root/.ssh \
  -v ${HOME}/.gitconfig:/root/.gitconfig \
  -v ${HOME}/.apollo:/root/.apollo \
  wearep3r/apollo:latest
```

**PRO TIP**: Save this **alias** to your `.zshrc` or `.bashrc` file to get quick access to **apollo**:

```bash
alias apollo="mkdir -p $HOME/.apollo; docker run --rm -it --name apollo -v ${HOME}/.ssh:/root/.ssh -v ${HOME}/.gitconfig:/root/.gitconfig -v ${HOME}/.apollo:/root/.apollo wearep3r/apollo:latest"
```

### Create your first space

Open a new terminal and run `apollo`. You will be presented with a prompt from inside the **apollo** Container:

```bash
~/.apollo/.spaces
❯  
```

You're inside your **spaces directory** (aka `APOLLO_SPACES_DIR`). From here you can create a new **space** by simply running `init`.

You will be guided through the creation of a new space.

1. Give your **space** a name (**hint**: use a `hostname` formatted name (e.g. `apollo-demo-1`) as it will be used in the **space** urls)
2. If you want to sync your space with a remote git repository, type `y`, otherwise just press enter
3. If you want to use one of apollo's supported cloud providers, enter the tag here, otherwise just press enter (**hint**: you will be asked for credentials if you choose a cloud provider)
4. Enter the ip-addresses of the nodes you want to be a manager in your apollo cluster (**hint**: enter multiple ips comma-separated, e.g. `192.168.178.187,192.168.178.188`)
5. Enter the ip-addresses of the nodes you want to be a worker in your apollo cluster (**hint**: enter multiple ips comma-separated, e.g. `192.168.178.197,192.168.178.198`)
6. Enter your desired base-domain (e.g. `mydomain.com` - your apollo cluster will run on `apollo-demo-1.mydomain.com`) if you have one, otherwise just press enter (we use **xip.io** wildcard DNS to provide a useful url for your apollo cluster out-of-the-box: `apollo-demo-1.192.168.178.187.xip.io`)
7. If you want to use LetsEncrypt, type `y`, otherwise just press enter (**hint**: LetsEncrypt doesn't work without a public IP for your apollo cluster and you need to provide an e-mail address if you want to use LetsEncrypt)

```bash
[DEV] 🚀 .spaces init
[apollo] Initializing new Space
[apollo] Name: apollo-demo-1
[apollo-demo-1] Do you want to sync this Space with a remote repository? [y/N]
[apollo-demo-1] Cloud Provider (generic,hcloud,digitalocean,aws):
[apollo-demo-1] Manager IPs (comma separated): 192.168.178.187
[apollo-demo-1] Worker IPs (comma separated):
[apollo-demo-1] Base domain:
[apollo-demo-1] Enable LetsEncrypt? [y/N]
[apollo-demo-1] 🚀 Space: apollo-demo-1
[apollo-demo-1]  ∟ 🌐 Base Domain: 192.168.178.187.xip.io
[apollo-demo-1]  ∟ 🤖 User: admin
[apollo-demo-1]  ∟ 🙊 Password: insecure!
[apollo-demo-1] 🟢 Nodes:
[apollo-demo-1]  ∟ 🟢 apollo-demo-1-manager-0 - 192.168.178.187
[apollo-demo-1] ❌ Federation: Disabled
[apollo-demo-1] 🟢 Backplane: Enabled
[apollo-demo-1]  ∟ 🟢 Portainer: http://admin:insecure!@portainer.apollo-demo-1.192.168.178.187.xip.io
[apollo-demo-1]  ∟ 🟢 Traefik: http://admin:insecure!@proxy.apollo-demo-1.192.168.178.187.xip.io
[apollo-demo-1]  ∟ 🟢 Prometheus: http://admin:insecure!@prometheus.apollo-demo-1.192.168.178.187.xip.io
[apollo-demo-1]  ∟ 🟢 Grafana: http://grafana.apollo-demo-1.192.168.178.187.xip.io
[apollo-demo-1] 🔴 GitLab Runner: Disabled
[apollo-demo-1] 🔴 Apps: Disabled
```

**Congratulations!** You just created your first **apollo** space. You've been taken to your space directory (aka `APOLLO_SPACE_DIR`) automatically and can now take a look at your **space** config:

```bash
[DEV] 🚀 apollo-demo-1.space ls
.ssh
apollo.env
infrastructure.apollo.env
```

If you're using a cloud provider, certain necessary values **apollo** needs to operate will be automatically saved to `nodes.apolloenv` - amongst them `APOLLO_INGRESS_IP`. **apollo** generates SSH-Keys for you in `$APOLLO_SPACE_DIR/.ssh` which will be used to connect to the provisioned infrastructure.

In case you're using your own infrastructure, please add the following values (adjusted to your infrastructure) to `infrastructure.apollo.env` manually before proceeding.

```bash
APOLLO_INGRESS_IP=1.2.3.4
APOLLO_NODES_MANAGER=1.2.3.4
APOLLO_NODES_WORKER=
APOLLO_PRIVATE_INTERFACE=eth0
APOLLO_PROVIDER=generic
APOLLO_PUBLIC_INTERFACE=eth0
```

### Deploy a space

Using `deploy`, you can deploy your Ssace. Please note that for a successful deployment `APOLLO_INGRESS_IP` needs to have a useful value and needs to be accessible through SSH with the SSH-Keys generated during the init process.

```bash
🚀 apollo-demo-1.space deploy
```

## Advanced usage

### Architecture

**apollo** is organized in **Spaces**. Such a **Space** works as a private environment with a specific configuration and size (it's kind of a **Virtual Private Cloud**). A **Space** is designed to be ephemeral but offers strong capabilities for stateful workloads and long-living clusters.

You can [use GitLab to store and collaborate on **Spaces**](manage-spaces.md).

### Configuration

**apollo** is a PaaS toolkit and comes with a bundled IaaS component. The following outlines typical **Space** configurations. For more advanced use-cases, see [Advanced Configuration](advanced-configuration.md).

#### Default configuration

For the following, we assume to handle a **Space** called `apollo-demo`. A Space has sane defaults so it can be started with minimum configuration.

Each Space has a so called `INGRESS_IP` which refers to the node (a VM/Server in the cluster) handling all incoming traffic. Thus, the `INGRESS_IP` will be used for all things DNS and more. It's a vital part of how **apollo** works and defaults to `127.0.0.1` or the IP address of the first manager node.

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

Typically, IaaS is confgured in a file called `infrastructure.apolloenv` living in `$APOLLO_SPACE_DIR` (which defaults to `$APOLLO_SPACES_DIR/$APOLLO_SPACE` in the `apollo` container).

The **minimum viable config** to spin up IaaS would be:

```bash
APOLLO_PROVIDER=[hcloud|aws|digitalocean]
PROVIDER_API_KEY=
```

Where `PROVIDER_API_KEY` is actually `HCLOUD_TOKEN` or something similar, depending on your provider.

This would spin up **1 small Ubuntu 18.04 VM** at your cloud provider of choice. It will add 3 files to your **Space**:

- `infrastructure.apollo.plan` is a [Terraform Planfile](https://www.terraform.io/docs/commands/plan.html)
- `infrastructure.apollo.tfstate` is a [Terraform Statefile](https://www.terraform.io/docs/state/index.html)
- `nodes.apolloenv` contains configuration necessary for Apollo to deploy the PaaS component to the VM

#### PaaS

**apollo** reads its configuration from the **Environment**. It's designed to run in a container and export configuration found in the **Space** directory to the container's environment. This includes the aforementioned `nodes.apolloenv` that only exists if IaaS has been provisioned successfully or if you created it manually with information about your own hosts.

Assuming we use IaaS to provide infrastructure, the **minimum viable config** to deploy a platform with **apollo** would be:

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

**Pro-Tipp**: if you want to use your own domain - `beingyou.rocks` - add the following records to your DNS and set `APOLLO_BASE_DOMAIN=beingyou.rocks` in `apolloenv`:

```bash
@ apollo-demo.beingyou.rocks 213.45.74.3
* apollo-demo.beingyou.rocks 213.45.74.3
```

This would give you access to the following endpoints automagically:

- Portainer: [http://portainer.apollo-demo.beingyou.rocks](http://portainer.apollo-demo.beingyou.rocks)
- Traefik: [http://proxy.apollo-demo.beingyou.rocks](http://proxy.apollo-demo.beingyou.rocks)
- Prometheus: [http://prometheus.apollo-demo.beingyou.rocks](http://prometheus.apollo-demo.beingyou.rocks)
- Grafana: [http://grafana.apollo-demo.beingyou.rocks](http://grafana.apollo-demo.beingyou.rocks)

## Built With

- Ansible
- Terraform
- bash/zsh
- GitLab
- Docker
- make
- python
- docker-compose

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct, and the process for submitting pull/merge requests to us. This software is primarily developed and maintained on [GitLab](https://gitlab.com/p3r.one/apollo).

## Versioning

We use SemVer for versioning, automated by [shipmate](https://gitlab.com/peter.saarland/shipmate). For the versions available, see the tags on this repository.

## Authors

- Fabian Peter

See also the list of contributors who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

There's so many people to thank for being awesome and providing open source software and support for it.

## 🚀 Disclaimer

This software is maintained and commercially supported by [p3r.](https://www.p3r.one). You can reach us here:

- [Slack](https://join.slack.com/t/wearep3r/shared_invite/zt-d9ao21f9-pb70o46~82P~gxDTNy_JWw)
- [GitLab](https://gitlab.com/p3r.one)
- [GitHub](https://github.com/wearep3r/)
- [LinkedIn](https://www.linkedin.com/company/peter-saarland)
- [XING](https://www.xing.com/profile/Fabian_Peter4/cv)
