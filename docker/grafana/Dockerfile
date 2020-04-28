FROM grafana/grafana:latest

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ARG BUILD_DATE

COPY config/datasources /etc/grafana/provisioning/datasources/
COPY config/dashboards.yml /etc/grafana/provisioning/dashboards/
COPY config/dashboards /etc/grafana/dashboards/

RUN grafana-cli plugins install grafana-piechart-panel \
    #&& grafana-cli plugins install raintank-worldping-app \
    && grafana-cli plugins install kubernetes-app

ENV GF_SECURITY_ADMIN_PASSWORD=admin \
    GF_SECURITY_ADMIN_USER=admin \
    GF_PATHS_PROVISIONING=/etc/grafana/provisioning/

LABEL org.label-schema.build-date=$BUILD_DATE