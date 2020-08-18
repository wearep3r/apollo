# Example use-cases

This document outlines a few standard use-cases and how to implement them with **apollo**. Each of the examples is the **mimimum viable configuration** for an apollo space catering to the outlined use-case.

For the sake of simplicity, we assume a base config for all of the following examples:

```bash
APOLLO_SPACE=apollo-demo-1
APOLLO_NODES_MANAGER=192.168.178.187
```

## We need a single-node Docker-Host

**apollo.env**

```bash
APOLLO_PROVIDER=generic
APOLLO_SPACE=apollo-demo-1
```

**infrastructure.apollo.env**

```bash
APOLLO_NODES_MANAGER=192.168.178.187
```

## We need a multi-node Docker-Cluster

**apollo.env**

```bash
APOLLO_PROVIDER=generic
APOLLO_SPACE=apollo-demo-1
```

**infrastructure.apollo.env**

```bash
APOLLO_NODES_MANAGER=192.168.178.187,192.168.178.188,192.168.178.189
```

## We need to run Kubernetes

**apollo.env**

```bash
APOLLO_PROVIDER=generic
APOLLO_SPACE=apollo-demo-1
APOLLO_ORCHESTRATOR=k3s
APOLLO_BACKPLANE_ENABLED=0
APOLLO_APPS=rancher
```

**infrastructure.apollo.env**

```bash
APOLLO_NODES_MANAGER=192.168.178.187
APOLLO_NODES_WORKER=192.168.178.188,192.168.178.189
```

## We need hyperconverged storage for our applications

**NOTE**: this configuration expects you to have 3 dedicated RAW disks (unformatted) per node that [Storidge](https://www.storidge.com) can use.

**apollo.env**

```bash
APOLLO_PROVIDER=generic
APOLLO_SPACE=apollo-demo-1
APOLLO_ORCHESTRATOR=swarm
APOLLO_BACKPLANE_ENABLED=1
APOLLO_DATA=storidge
```

**infrastructure.apollo.env**

```bash
APOLLO_NODES_MANAGER=192.168.178.187
APOLLO_NODES_WORKER=192.168.178.188,192.168.178.189
```

## We need GitLab Runners. Lots of them. Cheap

**apollo.env**

```bash
APOLLO_PROVIDER=generic
APOLLO_SPACE=apollo-demo-1
RUNNER_ENABLED=1
```

**infrastructure.apollo.env**

```bash
APOLLO_NODES_MANAGER=192.168.178.187
APOLLO_NODES_WORKER=192.168.178.188,192.168.178.189
```

## We need a stable backup solution based on S3

**apollo.env**

```bash
APOLLO_PROVIDER=generic
APOLLO_SPACE=apollo-demo-1
APOLLO_APPS=minio
```

**infrastructure.apollo.env**

```bash
APOLLO_NODES_MANAGER=192.168.178.187
```

## We need multiple compute environments (staging, production)

Use one of the other examples and duplicate it with different values for:

- APOLLO_SPACE
- APOLLO_NODES_MANAGER / APOLLO_NODES_WORKER

## We need a stable solution to self-host apps

This gives you a single-node Docker Swarm.

**apollo.env**

```bash
APOLLO_PROVIDER=generic
APOLLO_SPACE=apollo-demo-1
```

**infrastructure.apollo.env**

```bash
APOLLO_NODES_MANAGER=192.168.178.187
```

## We need to spin up ephemeral clusters in CI/CD

Use one of the examples tuned to your needs. 

## We need a stable solution for federated monitoring with Prometheus

Use one of the examples tuned to your needs. Prometheus is included with apollo's backplane (`APOLLO_BACKPLANE_ENABLED=1`, enabled by default). Federation is currently WIP.