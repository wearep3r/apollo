# Shared tags
locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "environment" = var.environment,
    "provider" = "dash1"
  }

  all_tags = merge(local.common_tags, var.tags)
}

resource "hcloud_ssh_key" "ssh_key" {
  name       = "${var.environment}-ssh"
  public_key = file(var.ssh_public_key_file)
}

# Create a manager server
resource "hcloud_server" "manager" {
  count = var.manager_instances
  name = join("-",[var.environment,"manager",count.index])
  image = var.os_family == "ubuntu" ? "ubuntu-18.04" : "debian-10"
  server_type = var.manager_size
  #ssh_keys  = [hcloud_ssh_key.ssh_key.id]
  ssh_keys  = [hcloud_ssh_key.ssh_key.id]
  labels = local.all_tags
  location= var.region
}

# Create a worker server
resource "hcloud_server" "worker" {
  count = var.worker_instances
  name = join("-",[var.environment,"worker",count.index])
  image = var.os_family == "ubuntu" ? "ubuntu-18.04" : "debian-10"
  server_type = var.worker_size
  ssh_keys  = [hcloud_ssh_key.ssh_key.id]
  labels = local.all_tags
  location= var.region
}

#  create volume manager
resource "hcloud_volume" "manager" {
  count = var.volume_count * var.manager_instances
  name = "${var.environment}-manager-vol-${count.index}"
  size     = var.volume_size
  location= var.region
}

#  create volume worker
resource "hcloud_volume" "worker" {
  count = var.volume_count * var.worker_instances
  name = "${var.environment}-worker-vol-${count.index}"
  size     = var.volume_size
  location= var.region
}

#  attach volume manager
resource "hcloud_volume_attachment" "manager" {
  count = var.manager_instances*var.volume_count
  volume_id = hcloud_volume.manager[count.index].id
  server_id = element(hcloud_server.manager.*.id, floor(count.index / var.volume_count))
  automount = true
}

#  attach volume worker
resource "hcloud_volume_attachment" "worker" {
  count = var.worker_instances*var.volume_count
  volume_id = hcloud_volume.worker[count.index].id
  server_id = element(hcloud_server.worker.*.id, floor(count.index / var.volume_count))
  automount = true
}

#create network in hcloud
resource "hcloud_network" "cluster_network" {
  name = "${var.environment}-net"
  ip_range = var.cluster_network
}

#config location/type and ip range to network
resource "hcloud_network_subnet" "apollo" {
  network_id = hcloud_network.cluster_network.id
  type = "server"
  network_zone = var.cluster_network_zone
  ip_range   = var.cluster_network
}

#attach the network to manager instance
resource "hcloud_server_network" "managers" {
  count = var.manager_instances
  server_id = hcloud_server.manager[count.index].id
  network_id = hcloud_network.cluster_network.id
}

#attach the network to worker instance
resource "hcloud_server_network" "workers" {
  count = var.worker_instances
  server_id = hcloud_server.worker[count.index].id
  network_id = hcloud_network.cluster_network.id
}
