#FROM prom/alertmanager:v0.15.3
FROM prom/alertmanager:master

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

COPY config /etc/alertmanager/

RUN chmod +x /etc/alertmanager/docker-entrypoint.sh

ENTRYPOINT  [ "/etc/alertmanager/docker-entrypoint.sh" ]
CMD        [ "--config.file=/etc/alertmanager/alertmanager.yml", \
             "--storage.path=/alertmanager" ]

ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE