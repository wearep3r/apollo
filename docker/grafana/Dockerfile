ARG GRAFANA_VERSION="latest"

FROM grafana/grafana:${GRAFANA_VERSION}

ARG GF_INSTALL_IMAGE_RENDERER_PLUGIN="true"

ENV GF_PATHS_PLUGINS="/var/lib/grafana-plugins"

ENV GF_RENDERER_PLUGIN_CHROME_BIN="/usr/bin/chromium-browser"

ENV GF_SECURITY_ADMIN_PASSWORD=admin \
    GF_SECURITY_ADMIN_USER=admin \
    GF_PATHS_PROVISIONING=/etc/grafana/provisioning/

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

USER root

RUN mkdir -p "$GF_PATHS_PLUGINS" && \
    chown -R grafana:grafana "$GF_PATHS_PLUGINS"

RUN if [ $GF_INSTALL_IMAGE_RENDERER_PLUGIN = "true" ]; then \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk --no-cache  upgrade && \
    apk add --no-cache udev ttf-opensans chromium && \
    rm -rf /tmp/* && \
    rm -rf /usr/share/grafana/tools/phantomjs; \
fi

COPY config/datasources /etc/grafana/provisioning/datasources/
COPY config/dashboards.yml /etc/grafana/provisioning/dashboards/
COPY config/dashboards /etc/grafana/dashboards/

USER grafana

RUN if [ $GF_INSTALL_IMAGE_RENDERER_PLUGIN = "true" ]; then \
    grafana-cli \
        --pluginsDir "$GF_PATHS_PLUGINS" \
        --pluginUrl https://github.com/grafana/grafana-image-renderer/releases/latest/download/plugin-linux-x64-glibc-no-chromium.zip \
        plugins install grafana-image-renderer; \
fi

ARG GF_INSTALL_PLUGINS="grafana-clock-panel,grafana-simple-json-datasource,grafana-piechart-panel,kubernetes-app,raintank-worldping-app"

RUN if [ ! -z "${GF_INSTALL_PLUGINS}" ]; then \
    OLDIFS=$IFS; \
        IFS=','; \
    for plugin in ${GF_INSTALL_PLUGINS}; do \
        IFS=$OLDIFS; \
        grafana-cli --pluginsDir "$GF_PATHS_PLUGINS" plugins install ${plugin}; \
    done; \
fi

LABEL org.label-schema.build-date=$BUILD_DATE

ARG BUILD_DATE