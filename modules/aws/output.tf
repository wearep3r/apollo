output "APOLLO_NODES_MANAGER" {
 value = "${join(",",aws_eip.manager_eip.*.public_ip)}"
}

output "APOLLO_NODES_WORKER" {
 value = "${join(",",aws_eip.worker_eip.*.public_ip)}"
}

output "APOLLO_PROVIDER" {
 value = "aws"
}

output "APOLLO_CLUSTER_NETWORK" {
 value = aws_subnet.zero_subnet.cidr_block
}

output "APOLLO_INGRESS_IP" {
 value = aws_eip.manager_eip[0].public_ip
}

output "APOLLO_PUBLIC_INTERFACE" {
 value = "eth0"
}

output "APOLLO_PRIVATE_INTERFACE" {
 value = "eth0"
}