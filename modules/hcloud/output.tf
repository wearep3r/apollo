output "APOLLO_NODES_MANAGER" {
 value = "${join(",",hcloud_server.manager.*.ipv4_address)}"
}

output "APOLLO_NODES_WORKER" {
 value = "${join(",",hcloud_server.worker.*.ipv4_address)}"
}

output "APOLLO_CLUSTER_NETWORK" {
 value = hcloud_network.cluster_network.ip_range
}

output "APOLLO_INGRESS_IP" {
 #value = hcloud_server.manager[0].ipv4_address 
 value = length(hcloud_server.worker) > 0 ? hcloud_server.worker[0].ipv4_address : hcloud_server.manager[0].ipv4_address 
}

output "APOLLO_PUBLIC_INTERFACE" {
 value = "eth0"
}

output "APOLLO_PRIVATE_INTERFACE" {
  value = length(regexall("^cpx.*",  var.manager_size)) > 0 ? "enp7s0" : "ens10"
}
