# Backplane

 Configuration Variable | Options | Default |
|------------|-------|-------|
| APOLLO_BACKPLANE_ENABLED    | 1,0 | 1 |

## Requirements

- `APOLLO_ORCHESTRATOR=swarm`

## Ingress Proxy

## Monitoring

- [engine/docker](engine.md#-docker): metric export enabled

### Prometheus

Prometheus is available on `http://prometheus.$SPACE_DOMAIN`. 

#### Node Exporter

#### cAdvisor

### Grafana

Grafana is used to access Prometheus metrics and Loki logs. The webinterface is available on `http://grafana.$SPACE_DOMAIN`. A set of default dashboards is configured to give visibility into the cluster.

Additionally, Loki logs can be quried from Grafana's **Explore** section.

## Logging

The apollo backplane features a centralized logging server: ([grafana/loki](#-loki)). The engine will be configured to use Loki for logging. This enables access to container-, stack- and service-logs from within [Grafana](#-grafana)'s **Explore** section.

- [engine/docker](engine.md#-docker): [centralized logging enabled](../roles/apollo-engine-docker/templates/daemon.json.j2)

### Loki

Loki is exposed on `127.0.0.1:3100` for local access on every node. You can hook up your services to swarm overlay network `monitoring` and access Loki directly under its container dns-name `loki`.

### Promtail

Promtail is configured to tail `/var/log/*` and forward parsed log streams to Loki.

## Container Management
