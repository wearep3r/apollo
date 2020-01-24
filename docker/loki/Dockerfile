FROM grafana/loki:latest
LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ARG BUILD_DATE

COPY config /etc/loki

LABEL org.label-schema.build-date=$BUILD_DATE