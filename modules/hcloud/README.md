# dash1 for Hetzner Cloud

Terraform module to setup **dash1** as infrastructure for [apollo](https://gitlab.com/peter.saarland/apollo) on **Hetzner Cloud**. Key facts are:

- Ability to specify and deploy manager and worker instances
- support for single manager cluster
- Ability to add labels
- Ability to specify server size
- Ability to specify no of volumes
- Ability to specify a IP range for the private ip address
- Ability to add SSH Key (by Fingerprint)

## Supported Configuration Options

```bash
HCLOUD_TOKEN=...
TF_VAR_region=fsn1
TF_VAR_os_family=ubuntu

# Zero
TF_VAR_environment=apollo
TF_VAR_manager_instances=1
TF_VAR_worker_instances=0
TF_VAR_manager_size=cx11
TF_VAR_worker_size=cx11
TF_VAR_volume_count=0
TF_VAR_volume_size=50
TF_VAR_labels=apollo
TF_VAR_cluster_network_name=apollo
TF_VAR_cluster_network_zone=eu-central
TF_VAR_cluster_network=10.16.0.0/16
TF_VAR_ssh_key=
```