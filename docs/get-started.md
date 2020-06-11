# Get Started

## Table of Contents

[[_TOC_]]

## Zero - Turn-Key VPC

**Zero** is a platform to run applications upon. As such, **Zero** has the following features and characteristics:

- **Docker** as container runtime
- **Docker Swarm**, **vanilla Kubernetes** or **k3s** as orchestrator
- Scales from 1 to infinite nodes
- Automatically integrated with [Storidge](https://storidge.com/) container IO
- Can be deployed to any cluster of Ubuntu/Debian nodes
- Comes with integrations for AWS, DigitalOcean, HETZNER Cloud and VMware
- **Swarm only**: cool backplane (reverse-proxy, auto-ssl, monitoring, auto-backups, dashboards)!
- **Apps**: turn-key GitLab, Minio, GitLab Runner, Rancher, more to come ...
- CLI integration (TBD)

**The goal for zero is to get teams up and running fast, with a set of services to help them and infrastructure they do not need to worry about.**

Zero is highly scalable (you can start with 1 node and scale up infinitely) and comes with a shared storage layer so you don't have to think about data persistance too much. Your applications' data is available within your entire cluster and regularly backed up - automagically (**Swarm only**).

Zero comes with a pre-configured set of apps that integrate beautifully with each other - such as **GitLab, Sentry, Prometheus, Grafana, Loki, a user backend** and more. You simply enable them and start working!

Zero aims to accelerate your digital transformation and development process. It helps you to prototype rapidly, but also to deploy to production safely. Zero gets you going quickly, yet provides operational stability even in highly regulated and heterogeneous environments.

Zero is tailored to development teams. Made by seasoned operators, it contains everything a DevOps-enabled team needs to start changing the world, without worrying about Ops too much.

Zero runs on every major and minor cloud provider, as well as directly on bare-metal, embedded devices or platforms like Proxmox and VMWare.

Zero is follows an **Infrastructure as Code** design-pattern. The cluster, its state and the apps running on the platform are merely a function applied to the data stored in Zero's storage layer. Zero strictly separates data from application, which means that migrating between clusters is as easy as restoring a backup to a new cluster. Moving a cluster is as easy as providing new compute-resources at a different provider.

Zero is based on the latest technologies and design patterns. It strives to be fully automated. Zero greatly reduces the operational overhead in organizations. It's a DevOps platform, doing lots of the Ops work automagically for you. It also manages your Kubernetes cluster!

Zero's best friend is **if0**, a CLI tool that controls all of Zero's features. The idea behind Zero and if0 is to blend the differences between local, production, staging and CI environments and give Developers a transparent way to interact with the applications they develop or use to assist their development (like Sentry).

## From Zero to Hero in 3 simple steps

### 1. Download if0

```bash
curl | bash -
if0 version
```

### 2. Create your Zero VPC

```bash
if0 init

# Great! We found a GL_TOKEN and imported
# it to ~/.if0/if0.env
#
# if0 will create a **private** repository at
# gitlab.com derfabianpeter/$VPC_NAME automatically for you
#
# You can disable this by setting
# IF0_REPOSITORY_AUTO_CREATE=0
# in ~/.if0/if0.env
#

### Create your Zero VPC ###
Name: draconic-envelope-galore
Size (Horizontal; No of machines): 
Size (Vertical; Size of machines): 
Provider: [aws, digitalocean, hcloud]
Domain: $IP.xip.io

# Success! New VPC designed. Now go ship it!
```

### 3. Ship your Zero VPC

```bash
if0 ship
```

## Advanced usage

### Architecture

Zero is organized in **VPC**s aka **Virtual Private Clouds**. Such a **VPC** works as a private environment with a specific configuration and size. A VPC is designed to be ephemeral 

### Configuration

