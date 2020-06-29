# WITH defaults

variable "timeout" {
  type        = number
  description = "Timeout for API operations in seconds."
  default     = 900
}

variable "region" {
  type        = string
  description = "IBM cloud region to deploy to"
  default     = "eu-de"
}

variable "zone" {
  type        = string
  description = "IBM cloud zone to deploy to"
  default     = "eu-de-1"
}

variable "image" {
  type        = string
  description = "Name of the OS image to be used for all nodes"
  default     = "ubuntu-18.04-amd64"
}

variable "profile" {
  type        = string
  description = "Name of the resources profile (compute power) to be used for all nodes"
  default     = "cc1-32x64"
}

variable "environment" {
  type        = string
  description = "The name to be used within all ressources as an environment identifier"
  default     = "staging"
}

variable "manager_count" {
  type        = number
  description = "Number of manager instances in the zero cluster"
  default     = 1
}

variable "worker_count" {
  type        = number
  description = "Number of worker instances in the zero cluster"
  default     = 1
}

variable "satellite_count" {
  type        = number
  description = "Number of satellite instances in the zero cluster"
  default     = 1
}

# WITHOUT defaults

variable "access_token" {
  type        = string
  description = "API access key to the IBM cloud account"
}

variable "ssh_public_key_file" {
  type        = string
  description = "File path to the public SSH key to use to connect to all nodes"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the IBM cloud resources group all resources should be located int"
}
