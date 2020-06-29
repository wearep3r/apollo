output "ZERO_NODES_MANAGER" {
 value = "${join(",",digitalocean_droplet.manager.*.ipv4_address)}"
}

output "ZERO_NODES_WORKER" {
 value = "${join(",",digitalocean_droplet.worker.*.ipv4_address)}"
}

output "ZERO_PROVIDER" {
 value = "digitalocean"
}

output "ZERO_CLUSTER_NETWORK" {
 value = digitalocean_vpc.cluster_network.ip_range
}

output "ZERO_INGRESS_IP" {
 value = digitalocean_droplet.manager[0].ipv4_address 
}

output "ZERO_PUBLIC_INTERFACE" {
 value = "eth0"
}

output "ZERO_PRIVATE_INTERFACE" {
 value = "eth1"
}