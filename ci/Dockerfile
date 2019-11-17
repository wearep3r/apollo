# syntax=docker/dockerfile:1.0.0-experimental
FROM python:3.7.5-alpine3.10
MAINTAINER Fabian Peter <fabian@peter.saarland>

WORKDIR /usr/src/app

COPY ansible/requirements.yml requirements.yml

RUN apk add --no-cache \
    git \
    build-base \
    libffi-dev \
    openssl-dev \
    python3-dev
    
RUN pip install --no-cache-dir \
    git+https://github.com/ansible/ansible.git@devel \
    hcloud \
    jsondiff \
    ansible-lint \
    ansible-autodoc  \
    && ansible-galaxy install -r requirements.yml

COPY ansible .
CMD ["ansible", "-v"]