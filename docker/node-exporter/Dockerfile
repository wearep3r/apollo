FROM prom/node-exporter:v0.16.0

ENV NODE_ID=none

USER root

COPY conf /etc/node-exporter/
RUN chmod +x /etc/node-exporter/docker-entrypoint.sh

ENTRYPOINT  [ "/etc/node-exporter/docker-entrypoint.sh" ]
CMD [ "--path.sysfs=/host/sys", "--path.procfs=/host/proc", "--collector.textfile.directory=/etc/node-exporter/", "--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)", "--no-collector.ipvs"]