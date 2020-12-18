[!["apollo"](https://gitlab.com/p3r.one/apollo/-/raw/v3.0.0/logo.png)](https://github.com/wearep3r/apollo)

**[Website](https://www.p3r.one)** — **[Documentation](https://gitlab.com/p3r.one/apollo)** — **[Source Code](https://gitlab.com/p3r.one/apollo)**

A python CLI to create and manage k3s clusters. Get going with Kubernetes in Docker or on any of our supported infrastructure providers in under 5 minutes.

[!["Version"](https://img.shields.io/github/v/tag/wearep3r/apollo?label=version)](https://github.com/wearep3r/apollo)
[!["GitLab Stars"](https://img.shields.io/badge/dynamic/json?color=orange&label=GitLab%20stars&query=%24.star_count&url=https%3A%2F%2Fgitlab.com%2Fapi%2Fv4%2Fprojects%2F17046783)](https://gitlab.com/p3r.one/apollo)
[!["GitHub Stars"](https://img.shields.io/github/stars/wearep3r/apollo?logo=github)](https://github.com/wearep3r/apollo)
[!["Docker Image Size"](https://img.shields.io/docker/image-size/wearep3r/apollo?logo=docker&label=Image)](https://hub.docker.com/r/wearep3r/apollo)
[!["p3r. Slack"](https://img.shields.io/badge/slack-@wearep3r/general-purple.svg?logo=slack&label=Slack)](https://join.slack.com/t/wearep3r/shared_invite/zt-d9ao21f9-pb70o46~82P~gxDTNy_JWw)

---

## Features

- Works on macOS, Linux and Windows
- Deploy a single-node k3s cluster in Docker (or Docker for Desktop) in less than a minute
- Start with a simple development environment, grow into production with ease
- Integrates with Ansible and Terraform
- Integrates with any major infrastructure provider
- Integrates with any major CI/CD system

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

1. You supply [minimum configuration](#getting-started) to create a cluster (`apollo init`)
2. apollo creates infrastructure if needed (`apollo create`)
3. apollo configures the machines and sets up k3s (`apollo install`)

Check the [Getting Started](#getting-started) section to start your journey with apollo.

## Philosophy

These are the design principles we base our work on apollo on. It's heavily inspired by DevOps and Clean Code practices and the works and arts of Martin Fowler who brought us immutable infrastructure. Still a long way to go. 

- Developers and operators should be able to trust their infrastructure and platform
- Every **space** should be versioned in a repository
- Configuration should be declarative
- There should be one workflow for installation and deployment that applies to all spaces
- No manual actions on the platform - everything must be code
- Every change to infrastructure should be code-reviewed to:
  - avoid mistakes
  - make other team members able to learn
  - make sure everything stays portable and immutable
- Everyone SHOULD be able to:
  - create their development environment with minimum effort
  - reproduce a production-like environment
  - understand the whole infrastructure
  - propose modifications to the infrastructure, while being able to test them
- apollo is a boilerplate and a framework - it should be customizable but still predictable

apollo is tailored to development teams. It's made by seasoned operators and contains everything a DevOps-enabled team needs to start changing the world.

It runs on every major and minor cloud provider or directly on bare-metal. IoT devices or platforms like Proxmox and VMWare are currently on the roadmap.

apollo is based on the latest technologies and design patterns. We're working hard to make it fully automated but it already reduces lots of the operational overhead in organizations. It's a DevOps platform, doing ops work automagically for you, so you can do developer magic on top of it.

## Technical prerequisites

- python3 >= 3.9
- Docker (optional)

## Prerequisites

You need to install [Docker](https://docs.docker.com/get-docker/). Once done, create a directory that holds apollo's configuration and the [spaces](#-) apollo manages:

```bash
mkdir -p $HOME/.apollo
```

## Installing apollo

```bash
pip3 install apollo
```

## Initalizing a cluster

This creates a configuration file (`.apollorc.yml`) from the defaults in your current directory. You can customize it to your needs before creating the cluster.

```bash
apollo init
```

## Creating a cluster

This bootstraps the necessary infrastructure resources (e.g. servers at a cloud provider of your choice; a local Docker container by default) to run k3s.

```bash
apollo create
```

From now on we will assume you created the alias for quick access to apollo.

## Installing k3s

This installs k3s and connects all the parts needed for a working cluster.

> NOTE: this step is not necessary when running k3s in Docker (which is the default) as the Docker image has everything pre-installed

```bash
apollo install
```

## Using your cluster

From inside your cluster's configuration directory, you can use apollo to invoke `kubectl` to interface with your cluster. apollo automatically creates a `kubeconfig.yml` in your cluster's configuration directory.

```bash
apollo k get nodes
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull/merge requests to us. This software is primarily developed and maintained on [GitLab](https://gitlab.com/p3r.one/apollo).

## Versioning

We use SemVer for versioning, automated by [shipmate](https://gitlab.com/peter.saarland/shipmate). For the versions available, see the tags on this repository.

## Authors

- Fabian Peter

See also the list of contributors who participated in this project.

## License

apollo is [fair-code](http://faircode.io/) licensed under [Apache 2.0 with Commons Clause](LICENSE.).

Additional information about license can be found in the FAQ.

Which license does n8n use?
n8n is fair-code licensed under Apache 2.0 with Commons Clause

### Is apollo Open-Source

No. The Commons Clause that is attached to the Apache 2.0 license takes away some rights. Hence, according to the definition of the Open Source Initiative (OSI), apollo is not open-source. Nonetheless, the source code is open and everyone (individuals and companies) can use it for free. However, it is not allowed to make money directly with apollo.

For instance, one cannot charge others to host or support apollo. However, to make things simpler, we grant everyone (individuals and companies) the right to offer consulting or support without prior permission as long as it is less than 20,000 EUR (€20k) per annum. If your revenue from services based on apollo is greater than €20k per annum, we'd invite you to become a partner and apply for a license. If you have any questions about this, feel free to reach out to us at info@p3r.one.

### Why is apollo not open-source but fair-code licensed instead

We love open-source and the idea that everybody can freely use and extend what we wrote. Our community is at the heart of everything that we do and we understand that people who contribute to a project are the main drivers that push a project forward. So to make sure that the project continues to evolve and stay alive in the longer run, we decided to attach the Commons Clause. This ensures that no other person or company can make money directly with apollo. Especially if it competes with how we plan to finance our further development. For the greater majority of the people, it will not make any difference at all. At the same time, it protects the project.

As apollo itself depends on and uses a lot of other open-source projects, it is only fair that we support them back. That is why we have planned to contribute a certain percentage of revenue/profit every month to these projects.

We have already started with the first monthly contributions via Open Collective. It is not much yet, but we hope to be able to ramp that up substantially over time.

## Acknowledgments

There's so many people to thank for being awesome and providing open source software and support for it.

## Disclaimer

This software is maintained and commercially supported by [p3r.](https://www.p3r.one). You can reach us here:

- [Web](https://www.p3r.one)
- [Slack](https://join.slack.com/t/wearep3r/shared_invite/zt-d9ao21f9-pb70o46~82P~gxDTNy_JWw)
- [GitLab](https://gitlab.com/p3r.one)
- [GitHub](https://github.com/wearep3r/)
- [LinkedIn](https://www.linkedin.com/company/wearep3r)



## Update Dependency Roles

From `app/ansible` run: `ansible-galaxy install --roles-path roles/ -r requirements.yml`