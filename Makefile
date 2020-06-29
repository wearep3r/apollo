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
DOCKER_SHELLFLAGS ?= run --rm -it -e IF0_ENVIRONMENT=${IF0_ENVIRONMENT} --name zero -v ${PWD}:/zero -v ${HOME}/.if0/.environments/${IF0_ENVIRONMENT}:/root/.if0/.environments/zero -v ${HOME}/.gitconfig:/root/.gitconfig zero
ZERO_PROVIDER ?= generic
TF_STATE_PATH=${ENVIRONMENT_DIR}/appollo.tfstate
TF_PLAN_PATH=${ENVIRONMENT_DIR}/appollo.plan
ENVIRONMENT_DIR ?= ${HOME}/.if0/.environments/zero
PROVIDER_UPPERCASE=$(shell echo $(ZERO_PROVIDER) | tr  '[:lower:]' '[:upper:]')
VERBOSITY ?= 0
export ANSIBLE_VERBOSITY ?= ${VERBOSITY}

.PHONY: help
help:
>	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: load
load: /tmp/.loaded.sentinel

/tmp/.loaded.sentinel: $(shell find ${ENVIRONMENT_DIR} -type f -name '*.env') ## help
> @if [ ! -z $$IF0_ENVIRONMENT ]; then echo "Loading Environment ${IF0_ENVIRONMENT}"; fi
> @touch /tmp/.loaded.sentinel

# INFRASTRUCTURE
modules/${ZERO_PROVIDER}/.terraform: /tmp/.loaded.sentinel
> @cd modules/${ZERO_PROVIDER}
>	@terraform init -compact-warnings -input=false

/tmp/.validated.sentinel: modules/${ZERO_PROVIDER}/.terraform
>	@cd modules/${ZERO_PROVIDER}
> @export TF_VAR_environment=${IF0_ENVIRONMENT}
>	@terraform validate > /dev/null
> @touch /tmp/.validated.sentinel

.PHONY: plan
plan: ${TF_PLAN_PATH} ## Plan

# Plan
${TF_PLAN_PATH}: /tmp/.validated.sentinel
> @cd modules/${ZERO_PROVIDER}
> @terraform plan -lock=true -compact-warnings -input=false -out=${TF_PLAN_PATH} -state=${TF_STATE_PATH} 

.PHONY: apply
apply: plan ${TF_STATE_PATH}

${TF_STATE_PATH}: ${TF_PLAN_PATH}
> @cd modules/${ZERO_PROVIDER}
> terraform apply -compact-warnings -state=${TF_STATE_PATH} -auto-approve ${TF_PLAN_PATH}

.PHONY: destroy
destroy: 
> @cd modules/${ZERO_PROVIDER}
> @terraform destroy -compact-warnings -state=${TF_STATE_PATH} -auto-approve 
> @rm -rf /tmp/.*.sentinel
> @rm -rf ${TF_STATE_PATH} ${TF_STATE_PATH}.backup ${TF_PLAN_PATH} ${ENVIRONMENT_DIR}/infrastructure.appollo.env

.PHONY: infrastructure
infrastructure: ${ENVIRONMENT_DIR}/dash1-zero.env ## Generate the configuration for zero

${ENVIRONMENT_DIR}/infrastructure.appollo.env: ${TF_STATE_PATH}
> @cd modules/${ZERO_PROVIDER}
> @terraform output -state=${TF_STATE_PATH} | tr -d ' ' > ${ENVIRONMENT_DIR}/infrastructure.appollo.env

.PHONY: output
output:
> @cd modules/${ZERO_PROVIDER}
> terraform output -state=${TF_STATE_PATH} | tr -d ' '

.PHONY: show
show:
> @cd modules/${ZERO_PROVIDER}
> @terraform show ${TF_STATE_PATH}

# PLATFORM
.PHONY: platform
platform: /tmp/.loaded.sentinel
>	@ansible-playbook provision.yml --flush-cache

.PHONY: check
check: /tmp/.loaded.sentinel
>	@ansible-playbook provision.yml --flush-cache --check

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

.PHONY: setup
setup:
> @ansible -i inventory/zero.py all -m setup -e "ansible_ssh_private_key_file=${ENVIRONMENT_DIR}/.ssh/id_rsa"