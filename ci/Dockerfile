# syntax=docker/dockerfile:1.0.0-experimental
FROM python:3.7.5-alpine3.10
MAINTAINER Fabian Peter <fabian@peter.saarland>

WORKDIR /usr/src/app
COPY ansible/requirements.yml /tmp/requirements.yml
RUN apk add --no-cache --virtual build-dependencies git build-base libffi-dev openssl-dev python3-dev \
    && pip install --no-cache-dir git+https://github.com/ansible/ansible.git@devel \
    hcloud \
    jsondiff \
    ansible-lint \
    ansible-autodoc \
    && ansible-galaxy install -r /tmp/requirements.yml \
    && apk del build-dependencies
COPY . .
CMD ["ansible", "-v"]