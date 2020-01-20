FROM prom/alertmanager:v0.15.3

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ARG BUILD_DATE


COPY conf /etc/alertmanager/

LABEL org.label-schema.build-date=$BUILD_DATE

ENTRYPOINT  [ "/etc/alertmanager/docker-entrypoint.sh" ]
CMD        [ "--config.file=/etc/alertmanager/alertmanager.yml", \
             "--storage.path=/alertmanager" ]