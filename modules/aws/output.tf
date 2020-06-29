output "ZERO_NODES_MANAGER" {
 value = "${join(",",aws_eip.manager_eip.*.public_ip)}"
}

output "ZERO_NODES_WORKER" {
 value = "${join(",",aws_eip.worker_eip.*.public_ip)}"
}

output "ZERO_PROVIDER" {
 value = "aws"
}

output "ZERO_CLUSTER_NETWORK" {
 value = aws_subnet.zero_subnet.cidr_block
}

output "ZERO_INGRESS_IP" {
 value = aws_eip.manager_eip[0].public_ip
}

output "ZERO_PUBLIC_INTERFACE" {
 value = "eth0"
}

output "ZERO_PRIVATE_INTERFACE" {
 value = "eth0"
}