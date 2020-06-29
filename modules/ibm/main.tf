provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.access_token
  ibmcloud_timeout = var.timeout
  generation       = "1"
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

resource "ibm_is_vpc" "vpc" {
  name           = "zero-vpc"
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_security_group" "sg" {
  name           = "zero-security-group"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.group.id
}

# allow http(s) access to the outside
resource "ibm_is_security_group_rule" "out_all" {
  group     = ibm_is_security_group.sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 1
    port_max = 65535
  }
}

resource "ibm_is_security_group_rule" "out_dns_all" {
  group     = ibm_is_security_group.sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"

  udp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "ingress_all" {
  group     = ibm_is_security_group.sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0" # TOO OPEN for production

  tcp {
    port_min = 22
    port_max = 22000
  }
}

resource "ibm_is_subnet" "subnet" {
  name                     = "zero-subnet"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = var.zone
  total_ipv4_address_count = 256
  resource_group           = data.ibm_resource_group.group.id
}

resource "ibm_is_ssh_key" "ssh_key" {
  name       = "zero"
  public_key = file(var.ssh_public_key_file)
}

data "ibm_is_image" "ubuntu" {
  name = var.image
}

resource "ibm_is_instance" "manager" {
  count          = var.manager_count
  name           = "zero-${var.environment}-manager-${count.index + 1}"
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zone
  keys           = [ibm_is_ssh_key.ssh_key.id]
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.profile
  resource_group = data.ibm_resource_group.group.id

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet.id
    security_groups = [ibm_is_security_group.sg.id]
  }
}

resource "ibm_is_instance" "worker" {
  count          = var.worker_count
  name           = "zero-${var.environment}-worker-${count.index + 1}"
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zone
  keys           = [ibm_is_ssh_key.ssh_key.id]
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.profile
  resource_group = data.ibm_resource_group.group.id

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet.id
    security_groups = [ibm_is_security_group.sg.id]
  }
}

resource "ibm_is_instance" "satellite" {
  count          = var.satellite_count
  name           = "zero-${var.environment}-satellite-${count.index + 1}"
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zone
  keys           = [ibm_is_ssh_key.ssh_key.id]
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.profile
  resource_group = data.ibm_resource_group.group.id

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet.id
    security_groups = [ibm_is_security_group.sg.id]
  }
}

resource "ibm_is_floating_ip" "manager-ip" {
  count          = var.manager_count
  name           = "zero-manager-fip"
  target         = element(ibm_is_instance.manager, count.index).primary_network_interface[0].id
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_floating_ip" "worker-ip" {
  count          = var.worker_count
  name           = "zero-worker-fip"
  target         = element(ibm_is_instance.worker, count.index).primary_network_interface[0].id
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_floating_ip" "satellite-ip" {
  count          = var.satellite_count
  name           = "zero-satellite-fip"
  target         = element(ibm_is_instance.satellite, count.index).primary_network_interface[0].id
  resource_group = data.ibm_resource_group.group.id
}

