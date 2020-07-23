# Features

## Network

Apollo. handles networking and ingress by spanning a peer-to-peer Wireguard network between nodes and limiting access to the cluster through custom firewalling.

| Port | Description | Access | Condition |
|------------|-------|----------|-----|
| 22    | SSH |  ✅ | - |
| 23    | NTP |  ✅ | - |
| 80    | HTTP | ✅ | - |
| 443    | HTTPS | ✅ | - |
| 6443    | Kubernetes API | ✅ | `APOLLO_ORCHESTRATOR` in `k3s,k8s` |
| 5888    | VPN | ✅ | `wireguard` in `APOLLO_APPS` |
| 2222    | GitLab SSH | ✅ | `gitlab` in `APOLLO_APPS` |
| *    | ALL | ❌ | DROP all other traffic |

### Wireguard

Apollo. uses [Wireguard](https://www.wireguard.com/) to establish secure networking between nodes in a cluster.

## Engine

| Configuration Variables | Options | Default |
|------------|-------|-------|
| APOLLO_ENGINE    | docker | [docker](#-docker) |

### Docker

[Docker](https://www.docker.com/) is the default **Container Engine** in Apollo.

## Orchestrator

Apollo. uses a container orchestrator to run apps and workloads. Apollo. supports **Docker Swarm**, **k3s** and **k8s**.

| Configuration Variables | Options | Default |
|------------|-------|-------|
| APOLLO_ORCHESTRATOR    | swarm,k3s,k8s | [swarm](#-docker-swarm) |

### Docker Swarm

[Docker Swarm](https://docs.docker.com/engine/swarm/) is the default **Container Orchestrator** in Apollo.

### k3s

### k8s

## Distributed Storage

| Configuration Variable | Options | Default |
|------------|-------|-------|
| APOLLO_DATA    | generic,storidge | [generic](#-generic) |

### Generic

By default, Apollo. uses **local storage** (i.e. the default [Docker Storage Driver](https://docs.docker.com/storage/storagedriver/select-storage-driver/) which is **Overlay 2**). This is suitable for single-node clusters, but might not be sufficient for high-available stateful workloads on multi-node clusters.

### Storidge

Apollo. can be used to deploy Storidge clusters with ease. By default, Apollo. uses the **Community Edition** of Storidge which is limited to **5 Nodes** and **1 TB** of provisioned storage.

Read more on Storidge's [official docs](https://docs.storidge.com/introduction/how_it_works.html)

| Requirement | Value  |
|------------|-------|
| `APOLLO_DATA`    | storidge |
| Minimum Cluster Size    | 4 |
| Maximum Cluster Size    | 5 (Community Edition) |
| Raw Drivers    | 3 |
| Maximum Storage    | 1 TB |

### Longhorn

[Longhorn](https://github.com/longhorn/longhorn) does not (yet) come pre-configured, but can be installed from within [Rancher](#-rancher).

## Backplane

Apollo. features a pre-configured **Backplane** composed of various services that help with day-to-day operations, monitoring, visibility and alerting.

As outlined in the [Feature Matrix](getting-started.md#-feature-matrix), backplane services are not compatible with every orchestrator.

| Configuration Variable | Options | Default |
|------------|-------|-------|
| APOLLO_BACKPLANE_ENABLED    | 1,0 | 1 |

### Traefik

[Traefik](https://docs.traefik.io/v1.7/) is the **reverse proxy** of choice in Apollo. and handles all HTTP/HTTPS ingress traffic.

| Requirement | Value  |
|------------|-------|
| APOLLO_BACKPLANE_ENABLED   | 1 |

### LetsEncrypt

| Configuration Variable | Options | Default |
|------------|-------|-------|
| LETSENCRYPT_ENABLED    | 1,0 | 1 |
| LETSENCRYPT_MAIL    | you@example.com | le@$APOLLO_SPACE_DOMAIN |

[Traefik](#-traefik) can automatically obtain SSL certificates for services and apps in your Apollo. cluster. Enable LetsEncrypt and provide a valid e-mail address (this is a requirement by Traefik) for registration with LetsEncrypt. That's it.

SSL via **LetsEncrypt** is **enabled** by default.

### Monitoring

Monitoring is handled by [Prometheus](#-prometheus). A suite of metric-collectors (namely **node-exporter** and **dockerd-exporter**) will be deployed as part of the backplane. Additionally, Prometheus is configured to automatically scrape metrics from any compatible service inside an Apollo. cluster.

### Alerting

Alerting is handled by **alertmanager**. You can provide a Slack-Channel to be alerted.

| Configuration Variable | Options | Default |
|------------|-------|-------|
| SLACK_WEBHOOK    | URL | - |
| SLACK_CHANNEL    | monitoring | - |
| SLACK_USER    | monitoring | apollo |

### Portainer

| Options | Value |
|------------|-------|
| URL    | http(s)://portainer.$SPACE_DOMAIN |
| User    | $APOLLO_ADMIN_USER |
| Password    | $APOLLO_ADMIN_PASSWORD |

[Portainer](https://www.portainer.io/) is used to interface with Docker from a UI.

### Rancher

| Options | Value |
|------------|-------|
| URL    | http(s)://rancher.$SPACE_DOMAIN |
| User    | $APOLLO_ADMIN_USER |
| Password    | $APOLLO_ADMIN_PASSWORD |

[Rancher](https://rancher.com/) is used to interface with Kubernetes from a UI.

### Garbage Collection

To keep the Container Engine clean, Apollo. features a garbage-collection mechanism that cleans unused containers, networks and volumes on all nodes every 24h.

### Loki

[Loki](https://grafana.com/oss/loki/) is used to gather logs from all nodes and Docker-based services inside the Apollo. cluster.

Logs can be queried from within [Grafana](#-grafana).

### Prometheus

[Prometheus](https://prometheus.io/) is used to gather metrics inside the Apollo. cluster.

Prometheus gathers lots of metrics by default but can also be used to push own metrics.

[Grafana](#-grafana) is used to visualize those metrics.

### Grafana

| Options | Value |
|------------|-------|
| URL    | http(s)://grafana.$SPACE_DOMAIN |
| User    | $APOLLO_ADMIN_USER |
| Password    | $APOLLO_ADMIN_PASSWORD |

[Grafana](https://grafana.com/grafana/) is the central analytics platform on an Apollo. cluster. It comes with pre-configured dashboards for all default-metrics as well as an interface to stream logs (syslogs, container-logs, service-logs, custom logs, ...) inside the **Explore** section - powered by [Loki](#-loki)

### Backups

Automated backups to S3 are possible through [lake0](https://gitlab.com/peter.saarland/lake0) which features a restic-based **Continuous Replication** mechanism to keep your data safe.

| Configuration Variable | Options | Default |
|------------|-------|-------|
| RESTIC_REPOSITORY    | s3:https://$S3_ENDPOINT/$BUCKET | - |
| RESTIC_PASSWORD    | 12345678 | - |
| RESTIC_BACKUP_CRON    | - | `30 * * * *` |
| RESTIC_FORGET_ARGS    | - | `--prune --keep-last 10 --keep-hourly 5 --keep-daily 7 --keep-weekly 0 --keep-monthly 12 --keep-yearly 1` |
| RESTIC_JOB_ARGS    | - | `--exclude minio_minio-data` |

`$S3_ENDPOINT` might be a [Minio](#-minio) app inside the same or an external Apollo. cluster or an endpoint at AWS, Wasabi, whatever.

Please refere to the [restic docs](https://restic.readthedocs.io/en/latest/) for further information.

## Apps

### Gitlab

### Minio

### Statping

## Integrations

### GitLab

### Slack
