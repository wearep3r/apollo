FROM grafana/grafana:latest

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE

COPY config/datasources /etc/grafana/provisioning/datasources/
COPY config/dashboards.yml /etc/grafana/provisioning/dashboards/
COPY config/dashboards /etc/grafana/dashboards/

ENV GF_SECURITY_ADMIN_PASSWORD=admin \
    GF_SECURITY_ADMIN_USER=admin \
    GF_PATHS_PROVISIONING=/etc/grafana/provisioning/