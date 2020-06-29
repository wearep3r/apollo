variable "region" {
  type        = string
  description = "The datacenter region"
  default     = "fsn1"
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
    description = "No of manager server count"
    default = 1
}

variable "worker_instances" {
    description = "No of worker server count"
    default = 0
}

variable "volume_count" {
    description = "No of Volumes in a instance"
    default = 0
}

variable "volume_size" {
    type = number
    description = "Size of a Volume in an instance"
    default = 50
}

variable "os_family" {
    description = "server OS of the VM. valid values are ubuntu and debian"
    default = "ubuntu"
}

variable "manager_size" {
    description = "Size of the manager server instance"
    default = "cx11"
}

variable "worker_size" {
    description = "Size of the worker server instance"
    default = "cx11"
}

variable "tags" {
  description = "User-defined tags "
  type        = map
  default = {}   
}

variable "cluster_network_zone" {
    description = "network zone the network belongs to"
    default = "eu-central"
}

variable "cluster_network" {
    description = "IP Range of the whole Network which must span all included subnets and route destinations. Must be one of the private ipv4 ranges of RFC1918"
    default = "10.16.0.0/16"
}