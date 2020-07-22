FROM grafana/loki:master-841befa-amd64

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

COPY config /etc/loki
ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE