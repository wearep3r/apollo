#!make
#include .env

.PHONY: build provision

.DEFAULT_GOAL := help

build:
	docker build -t peter.saarland/zero:latest --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') -f Dockerfile .

provision:
	@ansible-playbook provision.yml --flush-cache

