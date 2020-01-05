FROM prom/prometheus:v2.15.1
# https://hub.docker.com/r/prom/prometheus/tags/

COPY config /etc/prometheus/
USER root
RUN chmod +x /etc/prometheus/docker-entrypoint.sh
USER nobody

ENTRYPOINT [ "/etc/prometheus/docker-entrypoint.sh" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus" ]