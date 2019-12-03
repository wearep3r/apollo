# syntax=docker/dockerfile:1.0.0-experimental
FROM python:3.7.5-alpine3.10
LABEL maintainer Fabian Peter <fabian@peter.saarland>

ARG DOCKER_COMPOSE_VERSION=1.25.0
ARG DOCKER_VERSION=19.03.5

ENV TERM xterm
ENV ZSH_THEME dracula

WORKDIR /usr/src/app

COPY ansible/requirements.yml requirements.yml

RUN apk add --no-cache \
    git \
    curl \
    httpie \
    tar \
    build-base \
    libffi-dev \
    openssl-dev \
    python3-dev

RUN curl -fsSL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" -o ~/docker.tgz \
    && tar xzvf ~/docker.tgz \
    && rm ~/docker.tgz \
    && chmod +x ~/docker/* \
    && sudo mv ~/docker/docker /usr/local/bin/ \
    && groupadd docker -g 999 \
    && usermod -aG docker coder \
    && curl -fsSL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o ~/docker-compose \
    && chmod +x ~/docker-compose \
    && sudo mv ~/docker-compose /usr/local/bin/
    
RUN pip install --no-cache-dir \
    git+https://github.com/ansible/ansible.git@devel \
    hcloud \
    jsondiff \
    ansible-lint \
    && ansible-galaxy install -r requirements.yml

COPY ansible .
CMD ["ansible", "-v"]
