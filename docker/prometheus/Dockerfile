FROM prom/prometheus:v2.5.0
# https://hub.docker.com/r/prom/prometheus/tags/

COPY config /etc/prometheus/

RUN chmod +x /etc/prometheus/docker-entrypoint.sh

ENTRYPOINT [ "/etc/prometheus/docker-entrypoint.sh" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus" ]