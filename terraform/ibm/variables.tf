variable "ibmcloud_api_key" {
}

variable "ssh_public_key" {
}

variable "resource_group_name" {
}

variable "generation" {
  default = "1"
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