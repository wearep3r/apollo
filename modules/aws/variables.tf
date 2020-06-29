variable "region" {
  type        = string
  description = "The datacenter region"
  default     = "eu-west-1"
}

variable "ssh_public_key_file" {
  type        = string
  description = "The SSH public key"
  default     = "/root/.apollo/.environments/apollo/.ssh/id_rsa.pub"
}

variable "environment" {
  type        = string
  description = "The name to be used within all resources as an environment identifier for apollo"
  default     = "apollo"
}

variable "manager_instances" {
    description = "No. of manager server count"
    default = 1
}

variable "worker_instances" {
    description = "No. of worker server count"
    default = 0
}

variable "manager_os_family" {
    description = "AMI to use for manager nodes"
    default = "ubuntu"
}

variable "worker_os_family" {
    description = "AMI to use for worker nodes"
    default = "ubuntu"
}

variable "manager_size" {
    description = "Size of the manager instance"
    default = "t2.large"
}

variable "worker_size" {
    description = "Size of the worker server instance"
    default = "t2.large"
}

variable "cidr_vpc" {
  type        = string
  description = "CIDR block to be used for the VPC network"
  default     = "10.16.0.0/16"
}

variable "cidr_subnet" {
  type        = string
  description = "CIDR block to be used for the single subnet in the VPC network"
  default     = "10.16.0.0/16"
}

variable "ami_selection" {
  type        = map
  description = "used to create dyanamic ami names from os types"
  default     =   {
      debian = "ami-0f2ed58082cb08a4d"
      # Exchanged AMI ID on June 22th because: 
      # https://rancher.com/docs/rancher/v2.x/en/cluster-provisioning/rke-clusters/windows-clusters/
      windows = "ami-01fb8c61e4a567e34"
      #windows = "ami-0c841cc412b3474b1"
      ubuntu = "ami-0701e7be9b2a77600"
  }
}

variable "device_name" {
  type        = map
  description = "used to create dyanamic device names for ebs volumes"
  default     =   {
      0 = "f"
      1 = "g"
      2 = "h"
      3 = "i"
      4 = "j"
      5 = "k"
      6 = "l"
      7 = "m"
      8 = "n"
      9 = "o"
  }
}

variable "volume_count" {
    type = number
    description = "Number of storage volumes in the apollo cluster"
    default = 0
}

variable "volume_size" {
    type = number
    description = "Size of a Volume in an instance"
    default = 50
}

variable "tags" {
  type        = map
  description = "The default tags to be assigned to all resources created by this template"
  default     = {}
}