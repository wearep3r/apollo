# Example use-cases

This document outlines a few standard use-cases and how to implement them with **apollo**. Each of the examples is the **mimimum viable configuration** for an apollo space catering to the outlined use-case.

## Hetzner Cloud

- Log in to [Hetzner Cloud Console](https://console.hetzner.cloud/projects)
- Create a new project
- Switch to the new project
- Switch to "Security" in the right sidebar
- Select tab "API-Tokens"
- Generate a new API token (read+write)
- Copy the API token to your Spacefile
- Configure your Hetzner Cloud infrastructure inside your Spacefile

## Single-node Docker Swarm Cluster on Hetzner Cloud

Spacefile.yml:

```bash
infrastructure:
  enabled: true
  manager:
    count: 1
    os_family: ubuntu-18.04
    size: cpx31
  provider: hcloud
providers:
  digitalocean:
    auth:
      token: $DO_TOKEN
  hcloud:
    auth:
      token: $HCLOUD_TOKEN
space:
  base_domain: demo.example.com
  mail: info@example.com
  name: apollo-1
  space_domain: apollo-1.demo.example.com
  version: 2.1.1
```

## Multi-Node Docker Swarm Cluster on Hetzner Cloud

```bash
infrastructure:
  enabled: true
  manager:
    count: 1
    os_family: ubuntu-18.04
    size: cpx31
  provider: hcloud
  worker:
    count: 3
    os_family: ubuntu-18.04
    size: cpx21
providers:
  digitalocean:
    auth:
      token: $DO_TOKEN
  hcloud:
    auth:
      token: $HCLOUD_TOKEN
space:
  base_domain: demo.example.com
  mail: info@example.com
  name: apollo-1
  space_domain: apollo-1.demo.example.com
  version: 2.1.1
```

## Multi-Node Docker Swarm Cluster with high-available storage on Hetzner Cloud

```bash
data:
  provider: storidge
infrastructure:
  enabled: true
  manager:
    count: 1
    os_family: ubuntu-18.04
    size: cpx31
    volume_count: 3
    volume_size: 30
  provider: hcloud
  worker:
    count: 3
    os_family: ubuntu-18.04
    size: cpx21
    volume_count: 3
    volume_size: 30
providers:
  digitalocean:
    auth:
      token: $DO_TOKEN
  hcloud:
    auth:
      token: $HCLOUD_TOKEN
space:
  base_domain: demo.example.com
  mail: info@example.com
  name: apollo-1
  space_domain: apollo-1.demo.example.com
  version: 2.1.1
```

## Multi-Node Kubernetes Cluster on Hetzner Cloud

```bash
orchestrator: k3s
infrastructure:
  enabled: true
  manager:
    count: 1
    os_family: ubuntu-18.04
    size: cpx41
  provider: hcloud
  worker:
    count: 3
    os_family: ubuntu-18.04
    size: cpx31
providers:
  digitalocean:
    auth:
      token: $DO_TOKEN
  hcloud:
    auth:
      token: $HCLOUD_TOKEN
space:
  base_domain: demo.example.com
  mail: info@example.com
  name: apollo-1
  space_domain: apollo-1.demo.example.com
  version: 2.1.1
```

## GitLab Runner cluster on Hetzner Cloud

Get your Runner Registration Token (RUNNER_TOKEN) from your project's or group's CI/CD settings page.

```bash
addons:
  gitlab-runner:
    build:
      enabled: true
    coordinator_url: https://gitlab.com
    deploy:
      enabled: false
    docker_image: docker:19.03.12
    enabled: false
    package_name: gitlab-runner
    package_version: 13.4.0
    registration_token: $RUNNER_TOKEN
    token: $RUNNER_TOKEN
infrastructure:
  enabled: true
  manager:
    count: 1
    os_family: ubuntu-18.04
    size: cpx31
    volume_count: 3
    volume_size: 30
  provider: hcloud
  worker:
    count: 3
    os_family: ubuntu-18.04
    size: cpx31
    volume_count: 3
    volume_size: 30
providers:
  digitalocean:
    auth:
      token: $DO_TOKEN
  hcloud:
    auth:
      token: $HCLOUD_TOKEN
space:
  base_domain: demo.example.com
  mail: info@example.com
  name: apollo-1
  space_domain: apollo-1.demo.example.com
  version: 2.1.1
```

## Mltiple compute environments (staging, production)

Use one of the other examples and duplicate it with different values space.name


## We need to spin up ephemeral clusters in CI/CD

Use one of the examples tuned to your needs. 

## We need a stable solution for federated monitoring with Prometheus

Use one of the examples tuned to your needs. Prometheus is included with apollo's backplane (`APOLLO_BACKPLANE_ENABLED=1`, enabled by default). Federation is currently WIP.