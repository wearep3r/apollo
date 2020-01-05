provider "digitalocean" {
    token = "9488ec8b8211e19c58f898b4314d89b69558e0082c721f0fec40c75beb6e40bc"
}
 
resource "digitalocean_droplet" "test" {
    name  = "tf-1"
    image = "ubuntu-18-04-x64"
    region = "fra1"
    size   = "512mb"
    ssh_keys = [23797886]
    backups = false
    monitoring = true
    private_networking = true
}

provisioner "remote-exec" {
    inline = ["sudo apt-get -qq install python -y"]
}

connection {
    private_key = "${file(var.private_key)}"
    user        = "ubuntu"
}