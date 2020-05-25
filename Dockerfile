FROM registry.gitlab.com/peter.saarland/ansible-boilerplate:latest

LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ENV ENVIRONMENT_DIR=/root/.if0/.environments/zero

RUN mkdir -p ${ENVIRONMENT_DIR} /root/.ssh /zero

WORKDIR /zero

COPY requirements.yml requirements.yml

RUN ansible-galaxy install --ignore-errors -r requirements.yml

COPY . .

RUN echo 'export PS1="[\$IF0_ENVIRONMENT] \W # "' >> /root/.bashrc

ENTRYPOINT ["./docker-entrypoint.sh"]

CMD ["/bin/bash"]

ARG BUILD_DATE

LABEL org.label-schema.build-date=$BUILD_DATE
