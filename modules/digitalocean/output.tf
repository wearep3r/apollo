output "APOLLO_NODES_MANAGER" {
 value = "${join(",",digitalocean_droplet.manager.*.ipv4_address)}"
}

output "APOLLO_NODES_WORKER" {
 value = "${join(",",digitalocean_droplet.worker.*.ipv4_address)}"
}

output "APOLLO_PROVIDER" {
 value = "digitalocean"
}

output "APOLLO_CLUSTER_NETWORK" {
 value = digitalocean_vpc.cluster_network.ip_range
}

output "APOLLO_INGRESS_IP" {
 #value = digitalocean_droplet.manager[0].ipv4_address 
 value = length(digitalocean_droplet.worker) > 0 ? digitalocean_droplet.worker[0].ipv4_address : digitalocean_droplet.manager[0].ipv4_address 
}

output "APOLLO_PUBLIC_INTERFACE" {
 value = "eth0"
}

output "APOLLO_PRIVATE_INTERFACE" {
 value = "eth1"
}