variable access_token {}
variable private_key_file {}
variable remote_user {}
variable ssh_key_id {}

provider "digitalocean" {
  token = var.access_token
}

resource "digitalocean_ssh_key" "zero-key" {
  name       = "do-default"
  public_key = file(join("", [var.private_key_file, ".pub"]))
}

resource "digitalocean_droplet" "zero-manager1" {
  name     = "zero-manager1"
  image    = "ubuntu-18-04-x64"
  region   = "fra1"
  size     = "s-2vcpu-4gb"
  ssh_keys = [digitalocean_ssh_key.zero-key.fingerprint]

  connection {
    type        = "ssh"
    user        = var.remote_user
    host        = digitalocean_droplet.zero-manager1.ipv4_address
    private_key = file(var.private_key_file)
  }
}
