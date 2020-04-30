FROM prom/node-exporter:v0.16.0

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ENV NODE_ID=none

USER root

COPY config /etc/node-exporter/
RUN chmod +x /etc/node-exporter/docker-entrypoint.sh

ENTRYPOINT  [ "/etc/node-exporter/docker-entrypoint.sh" ]
CMD [ "--path.sysfs=/host/sys", "--path.procfs=/host/proc", "--collector.textfile.directory=/etc/node-exporter/", "--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)", "--no-collector.ipvs"]

ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE