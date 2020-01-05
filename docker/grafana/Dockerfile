FROM grafana/grafana:latest

COPY datasources /etc/grafana/provisioning/datasources/
COPY dashboards.yml /etc/grafana/provisioning/dashboards/
COPY dashboards /etc/grafana/dashboards/

ENV GF_SECURITY_ADMIN_PASSWORD=admin \
    GF_SECURITY_ADMIN_USER=admin \
    GF_PATHS_PROVISIONING=/etc/grafana/provisioning/