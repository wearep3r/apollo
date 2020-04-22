#!make
include .env

.PHONY: build ssh-gen ssh do-setup do-teardown do-show provision destroy deploy deploy-local deploy-backplane deploy-backplane-local deploy-vagrant ibm-login ibm-rg-create ibm-rg-delete ibm-init ibm-plan ibm-setup ibm-teardown test-traefik test-portainer aws-init aws-plan aws-setup aws-teardown

build:
	docker build -t peter.saarland/zero:latest -f ./docker/zero/Dockerfile .

ssh-gen:
	ssh-keygen -t rsa -b 4096 -f ${SSH_PRIVATE_KEY_FILE}
ssh:
	ssh ${REMOTE_USER}@${INGRESS_IP} -i ${SSH_PRIVATE_KEY_FILE}

do-setup:
	cd terraform/digitalocean/dev \
		&& export TF_VAR_access_token=${DIGITALOCEAN_AUTH_TOKEN} \
		&& export TF_VAR_private_key_file=${SSH_PRIVATE_KEY_FILE} \
		&& export TF_VAR_digitalocean_ssh_key_id=${DIGITALOCEAN_SSH_KEY_ID} \
		&& export TF_VAR_remote_user=${REMOTE_USER} \
		&& terraform apply
do-teardown:
	cd terraform/digitalocean/dev \
		&& export TF_VAR_access_token=${DIGITALOCEAN_AUTH_TOKEN} \
		&& export TF_VAR_private_key_file=${SSH_PRIVATE_KEY_FILE} \
		&& export TF_VAR_digitalocean_ssh_key_id=${DIGITALOCEAN_SSH_KEY_ID} \
		&& export TF_VAR_remote_user=${REMOTE_USER} \
		&& terraform destroy
do-show:
	cd terraform/digitalocean/dev \
		&& terraform show

provision:
	@ansible-playbook provision.yml --flush-cache
destroy:
	@cd terraform/digitalocean/main \
    	&& terraform destroy -no-color -auto-approve

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
	ansible-playbook -i .vagrant/provisioners/ansible/inventory playbooks/provision-backplane.yml

ibm-login:
	ibmcloud login
	
ibm-rg-create:
	ibmcloud resource group-create ${IBM_RESOURCE_GROUP_ID}

ibm-rg-delete:
	ibmcloud resource group-delete ${IBM_RESOURCE_GROUP_ID}

ibm-init:
	cd terraform/ibm && terraform init
ibm-plan:
	cd terraform/ibm \
		&& export TF_VAR_ibmcloud_api_key=${IBM_ACCESS_KEY} \
		&& export TF_VAR_ssh_public_key=${SSH_PRIVATE_KEY_FILE}.pub \
		&& export TF_VAR_resource_group_name=${IBM_RESOURCE_GROUP_ID} \
		&& terraform plan
ibm-setup:
	cd terraform/ibm \
		&& export TF_VAR_ibmcloud_api_key=${IBM_ACCESS_KEY} \
		&& export TF_VAR_ssh_public_key=${SSH_PRIVATE_KEY_FILE}.pub \
		&& export TF_VAR_resource_group_name=${IBM_RESOURCE_GROUP_ID} \
		&& terraform apply

ibm-teardown:
	cd terraform/ibm \
		&& export TF_VAR_ibmcloud_api_key=${IBM_ACCESS_KEY} \
		&& export TF_VAR_ssh_public_key=${SSH_PRIVATE_KEY_FILE}.pub \
		&& export TF_VAR_resource_group_name=${IBM_RESOURCE_GROUP_ID} \
		&& terraform destroy

test-traefik:
	cd roles/zero-app-traefik \
		&& molecule test

test-portainer:
	cd roles/zero-app-portainer \
		&& molecule test

aws-init:
	cd terraform/aws && terraform init

aws-plan:
	cd terraform/aws \
		&& export TF_VAR_ssh_public_key=${SSH_PRIVATE_KEY_FILE}.pub \
		&& terraform plan
aws-setup:
	cd terraform/aws \
		&& export TF_VAR_ssh_public_key=${SSH_PRIVATE_KEY_FILE}.pub \
		&& terraform apply

aws-teardown:
	cd terraform/aws \
		&& export TF_VAR_ssh_public_key=${SSH_PRIVATE_KEY_FILE}.pub \
		&& terraform destroy
		
