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

export DOCKER_BUILDKIT=1

.PHONY: help
help:
>	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build:
> @docker image prune -f
> @docker build --pull --build-arg SHIPMATE_CARGO_VERSION="${SHIPMATE_CARGO_VERSION}" -t ${APOLLO_WHITELABEL_NAME} .

.PHONY: dev
dev: .SHELLFLAGS = ${DOCKER_SHELLFLAGS}
dev: SHELL := docker
dev:
> @dev

.PHONY: install-deps
install-deps:
> @npm install @semantic-release/exec @semantic-release/git @semantic-release/gitlab @semantic-release/changelog -D

.PHONY: version
version:
> @npx semantic-release --generate-notes false --dry-run

.PHONY: porter-update-version
porter-update-version:
> @echo "${SEMANTIC_VERSION}" || exit 1
> @sed -i -r "s|[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+|${SEMANTIC_VERSION}|g" porter.yaml

.PHONY: porter-build
porter-build:
> @${HOME}/.porter/porter build --name apollo --version ${SEMANTIC_VERSION}

.PHONY: porter-publish
porter-publish:
> @${HOME}/.porter/porter publish

.PHONY: release
release:
> @npx semantic-release

