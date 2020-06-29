# dash1 for Amazon Web Services

Terraform module to setup **dash1** as infrastructure for **zero** on **Amazon Web Services**. Key facts are:

- This module creates a single VPC with a single subnet
- Access is controlled by a single security group
- All managers, workers and satellites are deployed as EC2 instances
- `access_token` and `ssh_public_key_file` are required variables, all others provide defaults, see [variables.tf](./variables.tf)
- Public IPs of all nodes are provided as outputs

## Prerequisites

- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_SESSION_TOKEN` are properly populated

## TODOs

- storage

## Supported Configuration Options

```bash
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_SESSION_TOKEN=...
TF_VAR_region=fsn1
TF_VAR_os_family=ubuntu

# Zero

```