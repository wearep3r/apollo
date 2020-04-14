provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
  ibmcloud_timeout = var.ibmcloud_timeout
  generation       = "1"
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
  name = var.image
}

resource "ibm_is_instance" "manager1" {
  name           = "${var.basename}-manager1"
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zone
  keys           = [ibm_is_ssh_key.ssh_key.id]
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.profile
  resource_group = data.ibm_resource_group.group.id

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet1.id
    security_groups = [ibm_is_security_group.sg1.id]
  }
}

resource "ibm_is_instance" "worker1" {
  name           = "${var.basename}-worker1"
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zone
  keys           = [ibm_is_ssh_key.ssh_key.id]
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.profile
  resource_group = data.ibm_resource_group.group.id

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet1.id
    security_groups = [ibm_is_security_group.sg1.id]
  }
}

resource "ibm_is_floating_ip" "manager1-ip" {
  name           = "${var.basename}-manager1-fip"
  target         = ibm_is_instance.manager1.primary_network_interface[0].id
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_floating_ip" "worker1-ip" {
  name           = "${var.basename}-worker1-fip"
  target         = ibm_is_instance.worker1.primary_network_interface[0].id
  resource_group = data.ibm_resource_group.group.id
}

output "manager1-ip" {
    value = ibm_is_floating_ip.manager1-ip.address
}

output "worker1-ip" {
    value = ibm_is_floating_ip.worker1-ip.address
}
