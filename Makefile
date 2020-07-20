SHELL := bash
.ONESHELL:
#.SILENT:
.SHELLFLAGS := -eu -o pipefail -c
#.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := help

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
APP_NAME ?= $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_PATH))))

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

# Apollo
APOLLO_WHITELABEL_NAME ?= apollo
APOLLO_VERSION ?= latest

# Deprecated
IF0_ENVIRONMENT ?= ${APOLLO_WHITELABEL_NAME}
APOLLO_SPACE ?= ${IF0_ENVIRONMENT}

# Deprecated
ZERO_PROVIDER ?= generic
APOLLO_PROVIDER ?= ${ZERO_PROVIDER}

APOLLO_SPACE_DIR ?= ${HOME}/.${APOLLO_WHITELABEL_NAME}/.spaces
ENVIRONMENT_DIR ?= ${APOLLO_SPACE_DIR}

export HISTFILE="${ENVIRONMENT_DIR}/.history"
export TF_IN_AUTOMATION=1
export TF_VAR_environment=${APOLLO_SPACE}

DOCKER_SHELLFLAGS ?= run --rm -it -e APOLLO_DEVELOPMENT=1 -e APOLLO_SPACE=${APOLLO_SPACE} --name ${APOLLO_WHITELABEL_NAME} -v ${HOME}/.ssh:/root/.ssh -v ${HOME}/.gitconfig:/root/.gitconfig -v ${PWD}:/${APOLLO_WHITELABEL_NAME} -v ${HOME}/.${APOLLO_WHITELABEL_NAME}/:/root/.${APOLLO_WHITELABEL_NAME} ${APOLLO_WHITELABEL_NAME}:${APOLLO_VERSION}

TF_STATE_PATH=${ENVIRONMENT_DIR}/infrastructure.${APOLLO_WHITELABEL_NAME}.tfstate
TF_PLAN_PATH=${ENVIRONMENT_DIR}/infrastructure.${APOLLO_WHITELABEL_NAME}.plan

VERBOSITY ?= 0
export ANSIBLE_VERBOSITY ?= ${VERBOSITY}
export DOCKER_BUILDKIT=1

.PHONY: help
help:
>	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: load
load: /tmp/.loaded.sentinel

/tmp/.loaded.sentinel: $(shell find ${ENVIRONMENT_DIR} -type f -name '*.env') ## help
> @if [ ! -z $$APOLLO_SPACE ]; then echo "Loading Environment ${APOLLO_SPACE}"; fi
> @touch /tmp/.loaded.sentinel

# INFRASTRUCTURE
modules/${APOLLO_PROVIDER}/.terraform: /tmp/.loaded.sentinel
> @cd modules/${APOLLO_PROVIDER}
>	@terraform init -compact-warnings -input=false

/tmp/.validated.sentinel: modules/${APOLLO_PROVIDER}/.terraform
>	@cd modules/${APOLLO_PROVIDER}
> echo "ENV: ${TF_VAR_environment}"
>	@terraform validate > /dev/null
> @touch /tmp/.validated.sentinel

.PHONY: plan
plan: ${TF_PLAN_PATH} ## Plan

# Plan
${TF_PLAN_PATH}: /tmp/.validated.sentinel
> @cd modules/${APOLLO_PROVIDER}
> @terraform plan -lock=true -compact-warnings -input=false -out=${TF_PLAN_PATH} -state=${TF_STATE_PATH} 

.PHONY: apply
apply: plan ${TF_STATE_PATH}

${TF_STATE_PATH}: ${TF_PLAN_PATH}
> @cd modules/${APOLLO_PROVIDER}
> terraform apply -compact-warnings -state=${TF_STATE_PATH} -auto-approve ${TF_PLAN_PATH}

.PHONY: destroy
destroy: 
> @cd modules/${APOLLO_PROVIDER}
> @terraform destroy -compact-warnings -state=${TF_STATE_PATH} -auto-approve 
> @rm -rf /tmp/.*.sentinel
> @rm -rf ${TF_STATE_PATH} ${TF_STATE_PATH}.backup ${TF_PLAN_PATH} ${ENVIRONMENT_DIR}/nodes.apollo.env

.PHONY: infrastructure
infrastructure: ${ENVIRONMENT_DIR}/nodes.apollo.env ## apollo IaaS

${ENVIRONMENT_DIR}/nodes.apollo.env: ${TF_STATE_PATH}
> @cd modules/${APOLLO_PROVIDER}
> @terraform output -state=${TF_STATE_PATH} | tr -d ' ' > ${ENVIRONMENT_DIR}/nodes.apollo.env

.PHONY: output
output:
> @cd modules/${APOLLO_PROVIDER}
> terraform output -state=${TF_STATE_PATH} | tr -d ' '

.PHONY: show
show:
> @cd modules/${APOLLO_PROVIDER}
> @terraform show ${TF_STATE_PATH}

# PLATFORM
.PHONY: platform
platform: ## apollo PaaS
>	@ansible-playbook provision.yml --flush-cache

.PHONY: check
check: /tmp/.loaded.sentinel
>	@ansible-playbook provision.yml --flush-cache --check

# Development
.PHONY: build
build:
> @docker build --pull -t ${APOLLO_WHITELABEL_NAME} .

.PHONY: dev
dev: .SHELLFLAGS = ${DOCKER_SHELLFLAGS}
dev: SHELL := docker
dev:
> @zsh

.PHONY: ssh
ssh: ${ENVIRONMENT_DIR}/.ssh/id_rsa ${ENVIRONMENT_DIR}/.ssh/id_rsa.pub

${ENVIRONMENT_DIR}/.ssh/:
> @mkdir ${ENVIRONMENT_DIR}/.ssh/

${ENVIRONMENT_DIR}/.ssh/id_rsa ${ENVIRONMENT_DIR}/.ssh/id_rsa.pub: ${ENVIRONMENT_DIR}/.ssh/
> @ssh-keygen -b 4096 -t rsa -q -N "" -f ${ENVIRONMENT_DIR}/.ssh/id_rsa 

.PHONY: inventory
inventory:
> @python inventory/apollo.py --list | jq

.PHONY: setup
setup:
> @ansible -i inventory/apollo.py all -m setup -e "ansible_ssh_private_key_file=${ENVIRONMENT_DIR}/.ssh/id_rsa"