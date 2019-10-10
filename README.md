# DevOps for MBIO Cloud
This README will hold an overview of the contents of this repo. This iw WIP.


# Ansible
## Installation

- https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

## Prerequisites
The Playbooks used to build and maintain this infrastructure have some dependencies that are listed below.

```
ansible-galaxy install dev-sec.os-hardening
ansible-galaxy install dev-sec.ssh-hardening
ansible-galaxy install geerlingguy.ntp
ansible-galaxy install robertdebock.locale
ansible-galaxy install geerlingguy.pip
ansible-galaxy install geerlingguy.docker
ansible-galaxy install geerlingguy.security
ansible-galaxy install geerlingguy.git
```

## Overview
To get an idea of what Ansible does and how it works, please (for now) refer to [this link](https://docs.ansible.com/ansible/latest/user_guide/index.html). Over time, most of the functionality used for this project will be highlighted and explained in this README and complementing docs in [this directory](docs/).

Ansible is an SSH-based orchestration software used in terms of **Immutable Infrastructure** and **Infrastructure as Code**. In short words, you define what your infrastructure (hosts, services, configs, etc) should look and behave like - and Ansible will force your will upon the infrastructure.

### Inventory
Ansible works with static and dynamic inventories. For now, we're using static inventories in form of *files* (staging.yml, production.yml, development.yml) where all nodes our infrastructure is composed of will be listed alongside any meta-info we have about them.

### Playbooks
Ansible can be told to apply a set of instructions (called **Playbook**) to these nodes. The procedure is always the same:

- Ansible connects to the node via SSH
- Ansible gathers all possible information about the system it's tasked to work on
- Ansible parses your instructions (Playbook) task by task and checks if the state your task defines matches the state on the node
- If yes, Ansible does nothing
- If not, Ansible will apply your instructions to the node (e.g. change ownership of a file, etc)
  
Ansible does this on multiple nodes at a time in parallel which makes it the excellent candidate to automate this infrastructure.

The overall paradigm is "Idempotency", meaning Ansible helps to use a server as a replaceable ressource that can be deleted, respawned and reconfigured at any given time with **always** the exact same outcome. This enables ease migration, upgrades and changes on whole fleets of servers and services.

## PLAYGROUND
I've spun up a dev-machine at HETZNER that is listed as "mbio-test" in `staging.yml`. Ansible (as of this repository) is configured to use a specific SSH-Key (in `.ssh`) for any connection made to the inventory nodes, so you should be able to do the following out of the box to see it in action:

- [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- `git clone git@gitlab.com:mbio/mbiosphere/infrastructure.git`
- `cd infrastructure`
- `ansible-playbook -i staging configure-node.yml`

This should provision the node with the tasks configured in `configure-node.yml`. As it is already provisioned, there won't be (m)any changes, but it's a quick way to see how Ansible works.

Within this repository, Ansible has a dedicated `ansible.cfg` that, if Ansible is used from within this directory, will be favored over your local ansible.cfg. Adjust according to you needs.

## Provision Docker Node
From within this repository, execute the following command to configure the basics of a Docker-Node (Manager/Worker):

### For Staging
`ansible-playbook -i staging configure-node.yml`

### For Production
`ansible-playbook -i production configure-node.yml`