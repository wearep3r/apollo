FROM python:3.7.5-alpine3.10
LABEL maintainer="Fabian Peter <fabian@peter.saarland>"

ARG BUILD_DATE

ARG TERRAFORM_VERSION=0.12.18
ARG TERRAFORM_INVENTORY_VERSION=0.9

RUN mkdir /infrastructure \
    && cd /infrastructure
WORKDIR /infrastructure

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
    ansible-lint \
    docker-compose

# Terraform
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip \
    && unzip terraform.zip \
    && rm terraform.zip \
    && chmod +x terraform \
    && mv terraform /usr/local/bin/ \
    && terraform version

# terraform-invenvory
RUN curl -fsSL "https://github.com/adammck/terraform-inventory/releases/download/v0.9/terraform-inventory_${TERRAFORM_INVENTORY_VERSION}_linux_amd64.zip" -o terraform-inventory.zip \
    && unzip terraform-inventory.zip \
    && rm terraform-inventory.zip \
    && chmod +x terraform-inventory \
    && mv terraform-inventory /usr/local/bin/ \
    && terraform-inventory -version

COPY . .
RUN cd /infrastructure/ansible \
    && echo 'Ansible refuses to read from a world-writeable folder, hence' \
    && chmod -v 700 $(pwd) \
    && ansible-galaxy install --ignore-errors -r requirements.yml

LABEL org.label-schema.build-date=$BUILD_DATE

WORKDIR /infrastructure
CMD ["ansible", "-v"]