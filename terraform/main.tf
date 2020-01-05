// curl -X GET -H "Content-Type: application/json" \
//    -H "Authorization: Bearer $API_TOKEN" \
//    "https://api.digitalocean.com/v2/account/keys"

variable "ssh_key_ids" { 
    type = list
    default = ["26180720"]
}

# variable "do_token" {
#     default = "9488ec8b8211e19c58f898b4314d89b69558e0082c721f0fec40c75beb6e40bc"
# }

# variable "ssh_key_path" {
#     default = "../.ssh/id_rsa"
# }

provider "digitalocean" {
  token = var.do_token
}

provider "hcloud" {
  token = var.hcloud_token
}

# resource "hcloud_network" "mbiosphere" {
#   name = "mbiosphere"
#   ip_range = "10.13.0.0/16"
# }
# resource "hcloud_network_subnet" "mbiosphere" {
#   network_id = hcloud_network.mbiosphere.id
#   type = "server"
#   network_zone = "eu-central"
#   ip_range   = "10.13.2.0/24"
# }

# resource "hcloud_server" "manager" {
#     count = 3
#     name = "manager-${count.index+1}"
#     image = "ubuntu-18.04"
#     server_type = "cx41"
#     location = "fsn1"
#     ssh_keys = ["MBio DevOps"]
#     labels = {
#         "swarm":"",
#         "docker":"",
#         "manager":""
#     }
#     backups = false

#     provisioner "remote-exec" {
#         inline = [
#             "uname -a",
#         ]
#         connection {
#         agent       = false
#         type        = "ssh"
#         private_key = file(var.ssh_key_path)
#         user        = "root"
#         timeout     = "5m"
#         host        = self.ipv4_address
#         }
#     }
# }

# resource "hcloud_server" "worker" {
#     count = 2
#     name = "worker-${count.index+1}"
#     image = "ubuntu-18.04"
#     server_type = "cx41"
#     location = "fsn1"
#     ssh_keys = ["MBio DevOps"]
#     labels = {
#         "swarm":"",
#         "docker":"",
#         "worker":""
#     }
#     backups = false

#     provisioner "remote-exec" {
#         inline = [
#             "uname -a",
#         ]
#         connection {
#         agent       = false
#         type        = "ssh"
#         private_key = file(var.ssh_key_path)
#         user        = "root"
#         timeout     = "5m"
#         host        = self.ipv4_address
#         }
#     }
# }

# resource "hcloud_server" "nfs" {
#     name = "nfs"
#     image = "ubuntu-18.04"
#     server_type = "cx41"
#     location = "fsn1"
#     ssh_keys = ["MBio DevOps"]
#     labels = {
#         "nfs":"",
#         "docker":""
#         "runner":""
#     }
#     backups = false

#     provisioner "remote-exec" {
#         inline = [
#             "uname -a",
#         ]
#         connection {
#         agent       = false
#         type        = "ssh"
#         private_key = file(var.ssh_key_path)
#         user        = "root"
#         timeout     = "5m"
#         host        = self.ipv4_address
#         }
#     }
# }

# resource "hcloud_server_network" "mbiosphere" {
#   network_id = hcloud_network.mbiosphere.id
#   server_id  = "${element(hcloud_server.manager.*.id, count.index)}"
#   count = 3
# }



resource "digitalocean_volume" "manager" {
  region                  = "fra1"
  count                   = var.volume_count * var.manager_count
  name                    = "manager-${count.index}"
  size                    = 50
  description             = "manager-${count.index}"
}


resource "digitalocean_volume" "worker" {
  region                  = "fra1"
  count                   = var.volume_count * var.worker_count
  name                    = "worker-${count.index}"
  size                    = 50
  description             = "worker-${count.index}"
}

# resource "digitalocean_volume" "manager-2" {
#   region                  = "fra1"
#   count                   = 3
#   name                    = "manager-2-${count.index + 1}"
#   size                    = 50
#   description             = "manager-2-${count.index + 1}"
# }

# resource "digitalocean_volume" "manager-3" {
#   region                  = "fra1"
#   count                   = 3
#   name                    = "manager-3-${count.index + 1}"
#   size                    = 50
#   description             = "manager-3-${count.index + 1}"
# }

# resource "digitalocean_volume" "worker-1" {
#   region                  = "fra1"
#   count                   = 3
#   name                    = "worker-1-${count.index + 1}"
#   size                    = 50
#   description             = "worker-1-${count.index + 1}"
# }

# resource "digitalocean_volume" "worker-2" {
#   region                  = "fra1"
#   count                   = 3
#   name                    = "worker-2-${count.index + 1}"
#   size                    = 50
#   description             = "worker-2-${count.index + 1}"
# }

resource "digitalocean_droplet" "manager" {
  count = var.manager_count
  ssh_keys           = var.ssh_key_ids
  image              = "ubuntu-18-04-x64"
  region             = "fra1"
  size               = "s-6vcpu-16gb"
  private_networking = true
  backups            = false
  monitoring         = true
  ipv6               = true
  name               = "manager-${count.index+1}"
  tags               = ["manager", "swarm", "mbiosphere", "docker", "cio"]
}

resource "digitalocean_volume_attachment" "manager" {
  count = var.manager_count * var.volume_count
  droplet_id = element(digitalocean_droplet.manager.*.id, floor(count.index % var.volume_count))
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
  tags               = ["worker", "swarm", "mbiosphere", "docker", "cio"]
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
  tags               = ["mbiosphere", "docker", "runner", "backplane", "local", "swarm"]
}

#   network_id = hcloud_network.mbiosphere.id
#   server_id  = "${element(hcloud_server.manager.*.id, count.index)}"
#   count = 3
# output "public_ips" {
#   value = "${digitalocean_droplet.manager.*.ipv4_address}"
# }

# output "private_ips" {
#   value = "${digitalocean_droplet.manager.*.ip}"
# }