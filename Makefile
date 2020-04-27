#!make
#include .env

.PHONY: build provision destroy deploy deploy-local deploy-backplane deploy-backplane-local deploy-vagrant test-traefik test-portainer 

build:
	docker build -t peter.saarland/zero:latest -f ./docker/zero/Dockerfile .

provision:
	@ansible-playbook provision.yml --flush-cache

deploy:
	docker run \
		-v "${PWD}/.env:/infrastructure/.env" \
		-v "${HOME}/.ssh:/.ssh" \
		--env-file=.env \
		registry.gitlab.com/peter.saarland/zero:latest \
		ansible-playbook -i inventory/zero.py provision.yml 

deploy-local:
	docker run \
		-v "${PWD}/.env:/infrastructure/.env" \
		-v "${HOME}/.ssh:/.ssh" \
		--env-file=.env \
		peter.saarland/zero:latest \
		ansible-playbook -i inventory/zero.py provision.yml 

deploy-backplane:
	docker run \
		-v "${PWD}/.env:/infrastructure/.env" \
		-v "${HOME}/.ssh:/.ssh" \
		--env-file=.env \
		registry.gitlab.com/peter.saarland/zero:latest \
		ansible-playbook playbooks/provision-backplane.yml 

deploy-backplane-local:
	docker run \
		-v "${PWD}/.env:/infrastructure/.env" \
		-v "${HOME}/.ssh:/.ssh" \
		--env-file=.env \
		peter.saarland/zero:latest \
		ansible-playbook playbooks/provision-backplane.yml 

deploy-vagrant:
	ansible-playbook -i .vagrant/provisioners/ansible/inventory provision.yml

ibm-login:
	ibmcloud login
	
ibm-rg-create:
	ibmcloud resource group-create ${IBM_RESOURCE_GROUP_ID}

ibm-rg-delete:
	ibmcloud resource group-delete ${IBM_RESOURCE_GROUP_ID}

deploy-vagrant:
	ansible-playbook -i .vagrant/provisioners/ansible/inventory provision.yml

test-traefik:
	cd roles/zero-app-traefik \
		&& molecule test

test-portainer:
	cd roles/zero-app-portainer \
		&& molecule test
