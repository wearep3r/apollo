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

DOCKER_SHELLFLAGS ?= run --rm -it --hostname apollo-dev -v ${HOME}/.docker:/root/.docker -v ${HOME}/.ssh:/root/.ssh -v ${HOME}/.gitconfig:/root/.gitconfig -v ${PWD}:/${APOLLO_WHITELABEL_NAME} -v ${HOME}/.${APOLLO_WHITELABEL_NAME}/:/root/.${APOLLO_WHITELABEL_NAME} ${APOLLO_WHITELABEL_NAME}:${APOLLO_VERSION}

export DOCKER_BUILDKIT=1

.PHONY: help
help:
>	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: publish-sem-rel
publish-sem-rel:
> git push origin master
> semantic-release publish

.PHONY: build-docker
build-docker:
#> @docker image prune -f
> docker build --build-arg BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION=$(shell apollo --version) --build-arg VCS_REF=$(shell git rev-parse --short HEAD) -t wearep3r/apollo .

.PHONY: publish-docker
publish-docker: build-docker
> docker tag wearep3r/apollo wearep3r/apollo:$(shell apollo --version)
> docker push wearep3r/apollo:$(shell apollo --version)
> docker tag wearep3r/apollo wearep3r/apollo:latest
> docker push wearep3r/apollo:latest

.PHONY: publish
publish: publish-docker
#> @docker image prune -f
> echo "Publishing"

.PHONY: dev
dev: .SHELLFLAGS = ${DOCKER_SHELLFLAGS}
dev: SHELL := docker
dev:
> @dev