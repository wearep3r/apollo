FROM grafana/loki:master-841befa-amd64

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ARG BUILD_DATE

COPY config /etc/loki

LABEL org.label-schema.build-date=$BUILD_DATE