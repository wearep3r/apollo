
variable "region" {
    type = string
    description = "The AWS region all resources are deployed to"
    default = "eu-central-1"
}

variable "instance_image_ami" {
    type = string
    description = "The AMI (identifier) of the AWS Ubuntu image to be used"
    default = "ami-0e342d72b12109f91" // 18.04 in eu-central-1 with ebs-ssd block storage, choose from https://cloud-images.ubuntu.com/locator/ec2/
}

variable "instance_type" {
    type = string
    description = "The AWS instance-type defining the amount of resources available to a EC2 instance"
    default = "t2.large" // 4vCPU, 16GB RAM, choose from https://aws.amazon.com/ec2/instance-types/
}

variable "cidr_vpc" {
    type = string
    description = "CIDR block to be used for the VPC network"
    default = "172.16.0.0/16"
}

variable "cidr_subnet" {
    type = string
    description = "CIDR block to be used for the single subnet in the VPC network"
    default = "172.16.10.0/24"
}

variable "instance_ip" {
    type = string
    description = "The IPv4 of the EC2 instances network interface"
    default = "172.16.10.100"
}

variable "availability_zone" {
    type = string
    description = "Identifier of the availability zone in the region to deploy the VPC subnet to"
    default = "eu-central-1a"
}

variable "ssh_public_key" {
    type = string
    description = "Path to the public key file to be used for deployment to EC2"
}

variable "tags" {
    type = map
    description = "The default tags to be assigned to all resources created by this template"
    default = {
        app = "zero"
        author = "peter.saarland"
    }
}