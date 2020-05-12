FROM registry.gitlab.com/peter.saarland/ansible-boilerplate

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

WORKDIR /ansible

COPY requirements.yml requirements.yml

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN ansible-galaxy install --ignore-errors -r requirements.yml \
    && chmod +x /docker-entrypoint.sh

COPY . .

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["ansible-playbook","-v"]

ARG BUILD_DATE

LABEL org.label-schema.build-date=$BUILD_DATE
