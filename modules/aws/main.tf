# Define AWS provider
provider "aws" {
  region     = var.region
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "environment" = var.environment,
    "provider" = "dash1"
  }

  all_tags = merge(local.common_tags, var.tags)
}

# Add Public Key as authorized
resource "aws_key_pair" "ssh_key" {
  public_key = file(var.ssh_public_key_file)
}

#create AWS security group
resource "aws_security_group" "apollo_sg" {
  vpc_id = aws_vpc.apollo_vpc.id
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
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 6556
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


data "template_file" "userdata_win" {
  template = <<EOF
<powershell>
$Source = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.1.0.0p1-Beta/OpenSSH-Win64.zip"
$zipfile = "c:\users\administrator\downloads\openssh.zip"
$targetDir = "C:\Program Files\OpenSSH"
$targetOpensshDir = $targetDir + "\OpenSSH-Win64"

Invoke-WebRequest $source -OutFile $zipfile
Expand-Archive $zipfile -DestinationPath $targetDir -Force
cd $targetOpensshDir
powershell.exe -ExecutionPolicy Bypass -File install-sshd.ps1
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=22
net start sshd
Set-Service sshd -StartupType Automatic

New-Item -path "C:\ProgramData\ssh\administrators_authorized_keys" -ItemType File -value "${file(var.ssh_public_key_file)}"
$acl = Get-Acl C:\ProgramData\ssh\administrators_authorized_keys
$acl.SetAccessRuleProtection($true, $false)
$administratorsRule = New-Object system.security.accesscontrol.filesystemaccessrule("Administrators","FullControl","Allow")
$systemRule = New-Object system.security.accesscontrol.filesystemaccessrule("SYSTEM","FullControl","Allow")
$acl.SetAccessRule($administratorsRule)
$acl.SetAccessRule($systemRule)
$acl | Set-Acl

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install --yes python3
</powershell>
<persist>false</persist>
EOF
}

#create elastic ip for manager
resource "aws_eip" "manager_eip" {
  count    = var.manager_instances
  vpc      = true
  instance = element(aws_instance.manager[*].id, count.index)
}

#create elastic ip for worker
resource "aws_eip" "worker_eip" {
  count    = var.worker_instances
  vpc      = true
  instance = var.worker_os_family == "windows" ? element(aws_instance.worker_win[*].id, count.index) : element(aws_instance.worker_lin[*].id, count.index)
}

# Create manager nodes
resource "aws_instance" "manager" {
  count                       = var.manager_instances
  ami                         = var.ami_selection[var.manager_os_family]
  instance_type               = var.manager_size
  vpc_security_group_ids      = [aws_security_group.apollo_sg.id]
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = aws_subnet.apollo_subnet.id
  associate_public_ip_address = true
  user_data                   = data.template_file.userdata_win.rendered

  credit_specification {
    cpu_credits = "unlimited"
  }
  tags = {
    Name = join("-",[var.environment,"manager",count.index])
  }
}

#create worker nodes for windows
resource "aws_instance" "worker_win" {
  count                       = var.worker_os_family == "windows" ? var.worker_instances : 0
  ami                         = var.ami_selection[var.worker_os_family]
  instance_type               = var.worker_size
  vpc_security_group_ids      = [aws_security_group.apollo_sg.id]
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = aws_subnet.apollo_subnet.id
  associate_public_ip_address = true
  user_data                   = data.template_file.userdata_win.rendered

  credit_specification {
    cpu_credits = "unlimited"
  }
  tags = {
    Name = join("-",[var.environment,"worker",count.index])
  }
}

#create worker nodes for linux variations
resource "aws_instance" "worker_lin" {
  count                       = var.worker_os_family != "windows" ? var.worker_instances : 0
  ami                         = var.ami_selection[var.worker_os_family]
  instance_type               = var.worker_size
  vpc_security_group_ids      = [aws_security_group.apollo_sg.id]
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = aws_subnet.apollo_subnet.id
  associate_public_ip_address = true

  credit_specification {
    cpu_credits = "unlimited"
  }
  tags = {
    Name = join("-",[var.environment,"worker",count.index])
  }
}

# #create worker nodes
# resource "aws_instance" "worker" {
#   count                       = var.worker_instances
#   ami                         = var.ami_selection[var.worker_os_family]
#   instance_type               = var.worker_size
#   vpc_security_group_ids      = [aws_security_group.apollo_sg.id]
#   key_name                    = aws_key_pair.ssh_key.key_name
#   subnet_id                   = aws_subnet.apollo_subnet.id
#   associate_public_ip_address = true
#   user_data                   = data.template_file.userdata_win.rendered

#   credit_specification {
#     cpu_credits = "unlimited"
#   }
#   tags = {
#     Name = join("-",[var.environment,"worker",count.index])
#   }
# }

#create ebs volume for manager
resource "aws_ebs_volume" "manager" {
  count             = var.manager_instances * var.volume_count
  availability_zone = "${var.region}a"
  size              = var.volume_size
}

#attaching ebs volume to manager
resource "aws_volume_attachment" "manager" {
  count       = var.manager_instances * var.volume_count
  device_name = "/dev/sd${var.device_name[count.index]}"
  volume_id   = "${element(aws_ebs_volume.manager.*.id, count.index)}"
  instance_id = element(aws_instance.manager.*.id, floor(count.index / var.volume_count))
}

#create ebs volume for worker
resource "aws_ebs_volume" "worker" {
  count             = var.worker_instances * var.volume_count
  availability_zone = "${var.region}a"
  size              = var.volume_size
}

#attaching ebs volume to worker
resource "aws_volume_attachment" "worker" {
  count       = var.worker_instances * var.volume_count
  device_name = "/dev/sd${var.device_name[count.index]}"
  volume_id   = "${element(aws_ebs_volume.worker.*.id, count.index)}"
  #instance_id = element(aws_instance.worker.*.id, floor(count.index / var.volume_count))
  instance_id = var.worker_os_family == "windows" ? element(aws_instance.worker_win[*].id, floor(count.index / var.volume_count)) : element(aws_instance.worker_lin[*].id, floor(count.index / var.volume_count))
}

#create vpc
resource "aws_vpc" "apollo_vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_hostnames = true
  enable_dns_support   = true
}

#create internet gateway
resource "aws_internet_gateway" "apollo_igw" {
  vpc_id = aws_vpc.apollo_vpc.id
}

#create subnet
resource "aws_subnet" "apollo_subnet" {
  vpc_id                  = aws_vpc.apollo_vpc.id
  cidr_block              = var.cidr_subnet
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
}

#create route table
resource "aws_route_table" "apollo_route_table" {
  vpc_id = aws_vpc.apollo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.apollo_igw.id
  }
}

#associate route table and subnet
resource "aws_route_table_association" "apollo_subnet_association" {
  subnet_id      = aws_subnet.apollo_subnet.id
  route_table_id = aws_route_table.apollo_route_table.id
}