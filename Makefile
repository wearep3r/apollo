#!make
include .env

setup:
	export TF_VAR_access_token=${DIGITALOCEAN_AUTH_TOKEN} \
		&& export TF_VAR_private_key_file=${SSH_PRIVATE_KEY_FILE} \
		&& export TF_VAR_remote_user=${REMOTE_USER} \
		&& terraform apply
teardown:
	export TF_VAR_access_token=${DIGITALOCEAN_AUTH_TOKEN} \
		&& export TF_VAR_private_key_file=${SSH_PRIVATE_KEY_FILE} \
		&& export TF_VAR_remote_user=${REMOTE_USER} \
		&& terraform destroy
show:
	terraform show
ssh-gen:
	ssh-keygen -t rsa -b 4096 -f ${SSH_PRIVATE_KEY_FILE}
ssh:
	ssh ${REMOTE_USER}@${INGRESS_IP} -i ${SSH_PRIVATE_KEY_FILE}
provision:
	@ansible-playbook provision.yml --flush-cache
destroy:
	@cd terraform \
    	&& terraform destroy -no-color -auto-approve
deploy:
	docker run \
		-v "${PWD}/.env:/infrastructure/.env" \
		-v "${HOME}/.ssh:/.ssh" \
		--env-file=.env \
		registry.gitlab.com/peter.saarland/zero:latest \
		ansible-playbook -i inventory/zero.py provision.yml 
		