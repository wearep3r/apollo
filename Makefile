SHELL := bash
.ONESHELL:
#.SILENT:
.SHELLFLAGS := -eu -o pipefail -c
#.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := help

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

export DOCKER_BUILDKIT=1
IF0_ENVIRONMENT ?= zero
DOCKER_SHELLFLAGS ?= run --rm -it -e IF0_ENVIRONMENT=${IF0_ENVIRONMENT} --name zero-${IF0_ENVIRONMENT} -v ${PWD}:/zero -v ${HOME}/.if0/.environments/${IF0_ENVIRONMENT}:/root/.if0/.environments/zero -v ${HOME}/.gitconfig:/root/.gitconfig zero
ZERO_PROVIDER ?= generic
ENVIRONMENT_DIR ?= ${HOME}/.if0/.environments/zero
PROVIDER_UPPERCASE=$(shell echo $(ZERO_PROVIDER) | tr  '[:lower:]' '[:upper:]')
ANSIBLE_V ?= 

.PHONY: help
help:
>	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: load
load: /tmp/.loaded.sentinel

/tmp/.loaded.sentinel: $(shell find ${ENVIRONMENT_DIR} -type f -name '*.env') ## help
> @if [ ! -z $$IF0_ENVIRONMENT ]; then echo "Loading Environment ${IF0_ENVIRONMENT}"; fi
> @touch /tmp/.loaded.sentinel

.PHONY: provision
provision: /tmp/.loaded.sentinel
>	@ansible-playbook provision.yml --flush-cache ${ANSIBLE_V}

.PHONY: retry
retry:
> @ansible-playbook provision.yml --limit @/root/.ansible/.retry/provision.retry

deploy:
>	@docker run \
		-v "${PWD}/.env:/infrastructure/.env" \
		-v "${HOME}/.ssh:/.ssh" \
		--env-file=.env \
		registry.gitlab.com/peter.saarland/zero:latest \
		ansible-playbook -i inventory/zero.py provision.yml 

deploy-vagrant:
>	ansible-playbook -i .vagrant/provisioners/ansible/inventory provision.yml

test-traefik:
>	cd roles/zero-app-traefik \
		&& molecule test

test-portainer:
>	cd roles/zero-app-portainer \
		&& molecule test

# Development
.PHONY: build
build:
> @docker build --pull -t zero .

.PHONY: dev
dev: .SHELLFLAGS = ${DOCKER_SHELLFLAGS}
dev: SHELL := docker
dev:
> @bash

.PHONY: ssh
ssh: ${ENVIRONMENT_DIR}/.ssh/id_rsa ${ENVIRONMENT_DIR}/.ssh/id_rsa.pub

${ENVIRONMENT_DIR}/.ssh/:
> @mkdir ${ENVIRONMENT_DIR}/.ssh/

${ENVIRONMENT_DIR}/.ssh/id_rsa ${ENVIRONMENT_DIR}/.ssh/id_rsa.pub: ${ENVIRONMENT_DIR}/.ssh/
> @ssh-keygen -b 4096 -t rsa -q -N "" -f ${ENVIRONMENT_DIR}/.ssh/id_rsa 

.PHONY: inventory
inventory:
> @python inventory/zero.py --list | jq