zero - Infrastructure in a Box
===

This README will hold an overview of the contents of this repo. This is **WIP**.

# Table of Contents
[[_TOC_]]

# Overview
This repository contains the code for the **zero** DevOps Platform. The code composes of a variety of mechanisms and tools that, together, build a Docker Swarm Based Platform and Backplane for modern App Deployments. The platform additionally features a distributed Storage Layer implemented with **Storidge**`**, spanning across Workers and Managers.

# Prerequisites

Currently, the Platform is designed to be run on Digitalocean, but any setup matching the following prerequisites should be able to operate **zero**:

## Minimum Requirements
- 1+ Ubuntu 18.04/Debian 10 Servers
- 4GM RAM
- 1 CPUs
- 20GB Local Disk

## Requirements for Storidge
- 4+ Ubuntu 18.04 Servers (with Kernel **4.15.0-74-generic**)
- 16GB RAM
- 4 CPUs
- 100GB Local Disk
- 3x 50GB+ raw Block Devices (unformatted disks, e.g. Block-Volumes from DigitalOcean)

# Configuration
**zero** accepts all configuration through Environment Variables. The available configuration options can be found in `.env.example`.

# Authentication
If not managed by another service (Auth0, LDAP, etc) authentication to all services inside the Platform is defined in variables `ADMIN_USER` and `ADMIN_PASSWORD`.

# Running it
Here's what you have to do to spin up **zero**:

1. Create the `.env` file with your settings (Hint: copy from `.env.example `)
2. Make sure **Docker** is installed
3. Have 1+ Servers ready with your SSH public key
4. Run **zero**: `docker run -v "${PWD}/.env:/infrastructure/.env" -v "${HOME}/.ssh:/.ssh" registry.gitlab.com/derfabianpeter/zero:latest ./if0 provision`

