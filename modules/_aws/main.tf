provider "aws" {
  region = var.region
}

locals {
  default_tags = {
    app         = "zero"
    environment = var.environment
  }

  all_tags = merge(local.default_tags, var.tags)
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.all_tags
}

resource "aws_key_pair" "ssh_key" {
  public_key = file(var.ssh_public_key_file)

  tags = local.all_tags
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = local.all_tags
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_subnet
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = local.all_tags
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = local.all_tags
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_instance" "manager" {
  count                       = var.manager_count
  ami                         = var.instance_image_ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = aws_subnet.subnet.id
  associate_public_ip_address = true

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = local.all_tags
}

resource "aws_instance" "worker" {
  count                       = var.worker_count
  ami                         = var.instance_image_ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = aws_subnet.subnet.id
  associate_public_ip_address = true

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = local.all_tags
}

resource "aws_instance" "satellite" {
  count                       = var.satellite_count
  ami                         = var.instance_image_ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = aws_subnet.subnet.id
  associate_public_ip_address = true

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = local.all_tags
}

resource "aws_eip" "manager_eip" {
  count    = var.manager_count
  vpc      = true
  instance = element(aws_instance.manager.*.id, count.index)

  tags = local.all_tags
}

resource "aws_eip" "worker_eip" {
  count    = var.worker_count
  vpc      = true
  instance = element(aws_instance.worker.*.id, count.index)

  tags = local.all_tags
}

resource "aws_eip" "satellite_eip" {
  count    = var.satellite_count
  vpc      = true
  instance = element(aws_instance.satellite.*.id, count.index)

  tags = local.all_tags
}
