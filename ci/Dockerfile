# syntax=docker/dockerfile:1.0.0-experimental
FROM python:3.7.5-alpine3.10
LABEL maintainer Fabian Peter <fabian@peter.saarland>

ARG DOCKER_COMPOSE_VERSION=1.25.0
ARG DOCKER_VERSION=19.03.5

ENV TERM xterm
ENV ZSH_THEME dracula

WORKDIR /usr/src/app

USER root

COPY ansible/requirements.yml requirements.yml

RUN apk add --no-cache \
    git \
    curl \
    httpie \
    tar \
    docker \
    build-base \
    libffi-dev \
    openssl-dev \
    python3-dev
    
RUN pip install --no-cache-dir \
    git+https://github.com/ansible/ansible.git@devel \
    hcloud \
    jsondiff \
    ansible-lint \
    docker-compose \
    && ansible-galaxy install -r requirements.yml

COPY ansible .
CMD ["ansible", "-v"]
