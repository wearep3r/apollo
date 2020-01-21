FROM traefik:v1.7.19-alpine

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ARG BUILD_DATE

COPY config /config

ENTRYPOINT ["/entrypoint.sh"]
CMD ["traefik","--configFile=/config/traefik.toml"]

LABEL org.label-schema.build-date=$BUILD_DATE