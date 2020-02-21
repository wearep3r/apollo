FROM prom/alertmanager:v0.15.3

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"


COPY config /etc/alertmanager/

RUN chmod +x /etc/alertmanager/docker-entrypoint.sh

ENTRYPOINT  [ "/etc/alertmanager/docker-entrypoint.sh" ]
CMD        [ "--config.file=/etc/alertmanager/alertmanager.yml", \
             "--storage.path=/alertmanager", \
             "--web.external-url=https://prometheus.mbiosphere.com" ]

ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE