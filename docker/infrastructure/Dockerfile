# syntax=docker/dockerfile:1.0.0-experimental
FROM python:3.7.5-alpine3.10
LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE

ARG DOCKER_VERSION=19.03.5
ARG DOCKER_COMPOSE_VERSION=1.25.1
ARG TERRAFORM_VERSION=0.12.18
ARG TERRAFORM_INVENTORY_VERSION=0.9

RUN mkdir /infrastructure

USER root

RUN apk add --no-cache \
    git \
    curl \
    httpie \
    tar \
    build-base \
    libffi-dev \
    openssl-dev \
    python3-dev
    
RUN pip install --no-cache-dir \
    ansible \
    hcloud \
    jsondiff \
    docker \
    ansible-lint

# Docker Compose
RUN curl -fsSL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o ~/docker-compose \
    && chmod +x ~/docker-compose \
    && sudo mv ~/docker-compose /usr/local/bin/ \
    && docker-compose --version

# Terraform
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o ~/terraform.zip \
    && unzip ~/terraform.zip \
    && rm ~/terraform.zip \
    && chmod +x ~/terraform \
    && sudo mv ~/terraform /usr/local/bin/ \
    && terraform version

# terraform-invenvory
RUN curl -fsSL "https://github.com/adammck/terraform-inventory/releases/download/v0.9/terraform-inventory_${TERRAFORM_INVENTORY_VERSION}_linux_amd64.zip" -o ~/terraform-inventory.zip \
    && unzip ~/terraform-inventory.zip \
    && rm ~/terraform-inventory.zip \
    && chmod +x ~/terraform-inventory \
    && sudo mv ~/terraform-inventory /usr/local/bin/ \
    && terraform-inventory -version

COPY . .

WORKDIR /infrastructure/ansible
RUN ansible-galaxy install -r requirements.yml
WORKDIR /infrastructure
CMD ["ansible", "-v"]