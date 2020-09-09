# DigitalOcean defines tags as resources, so we create our
# default tags here
resource "digitalocean_tag" "environment" {
  name = var.environment
}

resource "digitalocean_tag" "provider" {
  name = "apollo"
}

# Shared tags
locals {
  # Common tags to be assigned to all resources
  all_tags = [digitalocean_tag.provider.id, digitalocean_tag.environment.id]
}

resource "digitalocean_ssh_key" "ssh_key" {
  name       = "${var.environment}-ssh"
  public_key = file(var.ssh_public_key_file)
}

resource "digitalocean_volume" "manager" {
  region      = var.region
  count       = var.volume_count * var.manager_instances
  name        = "${var.environment}-manager-vol-${count.index}"
  size        = var.volume_size
  description = "${var.environment}-manager-vol-${count.index}"
  tags        = local.all_tags
}

resource "digitalocean_volume" "worker" {
  region      = var.region
  count       = var.volume_count * var.worker_instances
  name        = "${var.environment}-worker-vol-${count.index}"
  size        = var.volume_size
  description = "${var.environment}-worker-vol-${count.index}"
  tags        = local.all_tags
}

resource "digitalocean_droplet" "manager" {
  count              = var.manager_instances
  name               = "${var.environment}-manager-${count.index}"
  image              = var.os_family 
  region             = var.region
  size               = var.manager_size
  ssh_keys           = [digitalocean_ssh_key.ssh_key.fingerprint]
  private_networking = true
  vpc_uuid           = digitalocean_vpc.cluster_network.id
  backups            = false
  monitoring         = true
  ipv6               = true
  tags               = local.all_tags
}

resource "digitalocean_volume_attachment" "manager" {
  count      = var.manager_instances * var.volume_count
  droplet_id = element(digitalocean_droplet.manager.*.id, floor(count.index % var.manager_instances))
  volume_id  = element(digitalocean_volume.manager.*.id, count.index)
}

resource "digitalocean_droplet" "worker" {
  count              = var.worker_instances
  name               = "${var.environment}-worker-${count.index}"
  image              = var.os_family
  region             = var.region
  size               = var.worker_size
  ssh_keys           = [digitalocean_ssh_key.ssh_key.fingerprint]
  private_networking = true
  vpc_uuid           = digitalocean_vpc.cluster_network.id
  backups            = false
  monitoring         = true
  ipv6               = true
  tags               = local.all_tags
}

resource "digitalocean_volume_attachment" "worker" {
  count      = var.worker_instances * var.volume_count
  droplet_id = element(digitalocean_droplet.worker.*.id, floor(count.index / var.volume_count))
  volume_id  = element(digitalocean_volume.worker.*.id, count.index)
}

resource "digitalocean_vpc" "cluster_network" {
  name = "${var.environment}-net"
  region   = var.cluster_network_zone
  ip_range =  var.cluster_network
}
