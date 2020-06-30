# dash1 for Digitalocean

Terraform module to setup **dash1** as infrastructure for [apollo](https://gitlab.com/peter.saarland/apollo) on **DigitalOcean**. Key facts are:

- All managers, workers and satellites are deployed as droplets
- Volumes are used as storages and attached to all droplets
- `access_token` and `ssh_public_key_file` are required variables, all others provide defaults, see [variables.tf](./variables.tf)
- Public IPs of all nodes are provided as outputs

# Supported Configuration Options

```
DIGITALOCEAN_TOKEN=...
TF_VAR_region=fra1
TF_VAR_os_family=ubuntu

# Zero
TF_VAR_environment=apollo
TF_VAR_manager_instances=1
TF_VAR_worker_instances=0
TF_VAR_manager_size=s-2vcpu-4gb
TF_VAR_worker_size=s-2vcpu-4gb
TF_VAR_volume_count=0
TF_VAR_volume_size=50
TF_VAR_tags=apollo
TF_VAR_ssh_public_key_file=
```