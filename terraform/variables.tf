// these must be modified or set at runtime
variable "do_token" {
    default = "9488ec8b8211e19c58f898b4314d89b69558e0082c721f0fec40c75beb6e40bc"
}
variable "hcloud_token" {
    default = "hyflBkw1IVH1JVdrSHx8h0PeVmii5IRJcXSFIk0iu72KJXrHhi1fokNhM0d66TnA"
}
variable "ssh_user" {
    default = "devops"
}
variable "ssh_key_path" {
    default = "../.ssh/id_rsa"
}
variable "vm_ssh_key_ids" { 
    type = list
    default = ["26180720"]
}

// sane/cheap defaults from here-on out
variable "vm_num_of_droplets" {
  default = 5
}

variable "manager_count" {
  default = 3
}

variable "worker_count" {
  default = 2
}

variable "satellite_count" {
  default = 2
}

variable "volume_count" {
  default = 3
}

variable "vm_image" {
  default = "ubuntu-18-04-x64"
}
variable "vm_region" {
  default = "fra1"
}
variable "vm_size" {
  default = "s-1vcpu-1gb"
}
variable "vm_private_networking" {
  default = true
}
variable "vm_backups" {
  default = false
}
variable "vm_monitoring" {
  default = true
}
variable "vm_ipv6" {
  default = true
}
variable "vm_name" {
  default = "mbio-cloud"
}
variable "vm_tags" {
    default = ["manager", "mbiosphere"]
}
// variable "vm_volume_ids" {
//   default = []
// }
