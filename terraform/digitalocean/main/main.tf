// curl -X GET -H "Content-Type: application/json" \
//    -H "Authorization: Bearer $API_TOKEN" \
//    "https://api.digitalocean.com/v2/account/keys"

variable "ssh_key_ids" { 
    type = list
    default = ["23797886"]
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_volume" "manager" {
  region                  = "fra1"
  count                   = var.volume_count * var.manager_count
  name                    = "zero-${count.index}"
  size                    = 50
  description             = "zero-${count.index}"
}


resource "digitalocean_volume" "worker" {
  region                  = "fra1"
  count                   = var.volume_count * var.worker_count
  name                    = "worker-${count.index}"
  size                    = 50
  description             = "worker-${count.index}"
}

resource "digitalocean_droplet" "manager" {
  count = var.manager_count
  ssh_keys           = var.ssh_key_ids
  image              = "ubuntu-18-04-x64"
  #image               = "debian-10-x64"
  region             = "fra1"
  # s-2vcpu-4g
  #size               = "s-6vcpu-16gb"
  size               = "s-2vcpu-4gb"
  private_networking = true
  backups            = false
  monitoring         = true
  ipv6               = true
  name               = "zero-${count.index+1}"
  tags               = ["manager", "swarm", "docker", "cio", "storidge"]
}

resource "digitalocean_volume_attachment" "manager" {
  count = var.manager_count * var.volume_count
  droplet_id = element(digitalocean_droplet.manager.*.id, floor(count.index % var.manager_count))
  volume_id  = element(digitalocean_volume.manager.*.id, count.index)
}

resource "digitalocean_droplet" "worker" {
  count = var.worker_count
  ssh_keys           = var.ssh_key_ids
  image              = "ubuntu-18-04-x64"
  region             = "fra1"
  size               = "s-6vcpu-16gb"
  private_networking = true
  backups            = false
  monitoring         = true
  ipv6               = true
  name               = "worker-${count.index+1}"
  tags               = ["worker", "swarm", "docker", "cio"]
}

resource "digitalocean_volume_attachment" "worker" {
  count = var.worker_count * var.volume_count
  droplet_id = element(digitalocean_droplet.worker.*.id, floor(count.index / var.volume_count))
  volume_id  = element(digitalocean_volume.worker.*.id, count.index)
}

resource "digitalocean_droplet" "satellite" {
  count = var.satellite_count
  ssh_keys           = var.ssh_key_ids
  image              = "ubuntu-18-04-x64"
  region             = "fra1"
  size               = "s-6vcpu-16gb"
  private_networking = true
  backups            = false
  monitoring         = true
  ipv6               = true
  name               = "satellite-${count.index+1}"
  tags               = ["docker", "runner", "backplane", "local", "swarm"]
}
