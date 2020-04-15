variable "ibmcloud_api_key" {
}

variable "ssh_public_key" {
}

variable "resource_group_name" {
}

variable "ibmcloud_timeout" {
  description = "Timeout for API operations in seconds."
  default     = 900
}

variable "region" {
  default = "eu-de"
}

variable "zone" {
  default = "eu-de-1"
}

variable "basename" {
  description = "Name for the VPC to create and prefix to use for all other resources."
  default     = "zero"
}

variable "image" {
    default = "ubuntu-18.04-amd64"
}

variable "profile" {
    default = "cc1-32x64"
}