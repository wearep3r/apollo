output "ZERO_NODES_MANAGER" {
 value = "${join(",",hcloud_server.manager.*.ipv4_address)}"
}

output "ZERO_NODES_WORKER" {
 value = "${join(",",hcloud_server.worker.*.ipv4_address)}"
}

output "ZERO_PROVIDER" {
 value = "hcloud"
}

output "ZERO_CLUSTER_NETWORK" {
 value = hcloud_network.cluster_network.ip_range
}

output "ZERO_INGRESS_IP" {
 value = hcloud_server.manager[0].ipv4_address 
}

output "ZERO_PUBLIC_INTERFACE" {
 value = "eth0"
}

output "ZERO_PRIVATE_INTERFACE" {
  value = length(regexall("^cpx.*",  var.manager_size)) > 0 ? "enp7s0" : "ens10"
}
