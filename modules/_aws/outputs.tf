
output "manager_ip" {
  value = aws_eip.manager_eip.*.public_ip
}

output "worker_ip" {
  value = aws_eip.worker_eip.*.public_ip
}

output "satellite_ip" {
  value = aws_eip.satellite_eip.*.public_ip
}
