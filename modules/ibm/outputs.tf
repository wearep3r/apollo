output "manager-ip" {
  value = ibm_is_floating_ip.manager-ip.*.address
}

output "worker-ip" {
  value = ibm_is_floating_ip.worker-ip.*.address
}

output "satellite-ip" {
  value = ibm_is_floating_ip.satellite-ip.*.address
}
