variable "region" {
  type        = string
  description = "Region to deploy all resources to"
  default     = "fra1"
}

variable "environment" {
  type        = string
  description = "The name to be used within all ressources as an environment identifier"
  default     = "zero"
}

variable "ssh_public_key_file" {
  type        = string
  description = "SSH Public Key File"
  default     = "/root/.if0/.environments/zero/.ssh/id_rsa.pub"
}

variable "manager_instances" {
  type        = number
  description = "Number of manager instances in the zero cluster"
  default     = 1
}

variable "worker_instances" {
  type        = number
  description = "Number of worker instances in the zero cluster"
  default     = 0
}

variable "volume_count" {
  type        = number
  description = "Number of storage volumes in the zero cluster"
  default     = 0
}

variable "volume_size" {
  type        = number
  description = "The number of GBs assigned to each volume"
  default     = 50
}

variable "os_family" {
  type        = string
  description = "Image identifier of the OS image to be used"
  default     = "ubuntu-18-04-x64"
}

variable "manager_size" {
  type        = string
  description = "Computing size identifier to be used for the manager"
  default     = "s-2vcpu-4gb"
}

variable "worker_size" {
  type        = string
  description = "Computing size identifier to be used for the worker"
  default     = "s-2vcpu-4gb"
}

variable "cluster_network_zone" {
    description = "network zone the network belongs to"
    default = "fra1"
}

variable "cluster_network" {
    description = "IP Range of the whole Network which must span all included subnets and route destinations. Must be one of the private ipv4 ranges of RFC1918"
    default = "10.16.0.0/16"
}