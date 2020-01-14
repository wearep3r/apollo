FROM prom/prometheus:v2.15.1

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ARG BUILD_DATE

COPY config /etc/prometheus/
USER root
RUN chmod +x /etc/prometheus/docker-entrypoint.sh
USER nobody

LABEL org.label-schema.build-date=$BUILD_DATE

ENTRYPOINT [ "/etc/prometheus/docker-entrypoint.sh" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus" ]