provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"] # TOO OPEN FOR PRODUCTION
    from_port   = 22
    to_port     = 22
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

  tags = var.tags
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_subnet
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = var.tags
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = var.tags
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

# resource "aws_network_interface" "network_interface" {
#   subnet_id   = aws_subnet.subnet.id
#   private_ips = [var.instance_ip]

#   tags = var.tags
# }

resource "aws_instance" "node_instance" {
  ami                         = var.instance_image_ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.zero_key.key_name
  subnet_id                   = aws_subnet.subnet.id
  associate_public_ip_address = true

  #   network_interface {
  #     network_interface_id = aws_network_interface.network_interface.id
  #     device_index         = 0
  #   }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = var.tags
}

resource "aws_eip" "eip" {
  vpc      = true
  instance = aws_instance.node_instance.id

  tags = var.tags
}

resource "aws_key_pair" "zero_key" {
  key_name   = "zero-key"
  public_key = file(var.ssh_public_key)

  tags = var.tags
}

output "node_public_ip" {
  value = aws_eip.eip.public_ip
}
