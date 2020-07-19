# dash1 for aws EC2

Terraform module to setup **dash1** as infrastructure for [apollo](https://gitlab.com/peter.saarland/apollo) on **aws**. Key facts are:

- Ability to specify and deploy manager and worker instances
- support for single manager cluster
- support for hybrid cluster
- Ability to add labels
- Ability to specify server size
- Ability to specify no of volumes
- Ability to specify a IP range for the private ip address
- Ability to add SSH Key (by SSH file)

## Supported Configuration Options

```bash
TF_VAR_region=eu-west-1
TF_VAR_manager_os=ubuntu
TF_VAR_worker_os=ubuntu

# Zero
TF_VAR_environment=apollo
TF_VAR_manager_instances=1
TF_VAR_worker_instances=0
TF_VAR_manager_size=t2.large
TF_VAR_worker_size=t2.large
TF_VAR_volume_count=0
TF_VAR_volume_size=50
TF_VAR_labels=apollo
TF_VAR_cluster_network_zone=eu-west-1
TF_VAR_cluster_network=10.16.10.0/24
TF_VAR_ssh_key=
```