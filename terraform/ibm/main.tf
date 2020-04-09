provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
  ibmcloud_timeout = var.ibmcloud_timeout
  generation       = var.generation
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

resource "ibm_is_vpc" "vpc" {
  name           = var.basename
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_security_group" "sg1" {
  name           = "${var.basename}-sg1"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.group.id
}

# allow ssh access to this instance from anywhere on the planet
resource "ibm_is_security_group_rule" "ingress_ssh_all" {
  group     = ibm_is_security_group.sg1.id
  direction = "inbound"
  remote    = "0.0.0.0/0" # TOO OPEN for production

  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_subnet" "subnet1" {
  name                     = "${var.basename}-subnet1"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = var.zone
  total_ipv4_address_count = 256
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_ssh_key" "ssh_key" {
    name      = "zero"
	public_key = file(var.ssh_public_key)
}

data "ibm_is_image" "ubuntu" {
  name = var.generation == "1" ? "ubuntu-18.04-amd64" : "ibm-ubuntu-18-04-1-minimal-amd64-1"
}

resource "ibm_is_instance" "vsi1" {
  name           = "${var.basename}-vsi1"
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zone
  keys           = [ibm_is_ssh_key.ssh_key.id]
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.generation == "1" ? "cc1-2x4": "cx2-2x4"
  resource_group = data.ibm_resource_group.group.id

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet1.id
    security_groups = [ibm_is_security_group.sg1.id]
  }
}

resource "ibm_is_floating_ip" "fip1" {
  name           = "${var.basename}-fip1"
  target         = ibm_is_instance.vsi1.primary_network_interface[0].id
  resource_group = data.ibm_resource_group.group.id
}


