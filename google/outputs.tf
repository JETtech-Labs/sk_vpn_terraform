locals {
  network_interface = google_compute_instance.instance.network_interface[0]
  mgmt_nat_ip   = length(local.network_interface.access_config) > 0 ? local.network_interface.access_config[0].nat_ip : null
  wan_nat_ip   = length(local.network_interface.access_config) > 1 ? local.network_interface.access_config[1].nat_ip : null
  instance_ip       = coalesce(local.mgmt_nat_ip, local.network_interface.network_ip)
  
}

output "admin_url" {
  description = "Admin Url"
  value       = "https://${local.instance_ip}/"
}

output "instance_self_link" {
  description = "Self-link for the compute instance."
  value       = google_compute_instance.instance.self_link
}

output "instance_zone" {
  description = "Zone for the compute instance."
  value       = var.zone
}

output "instance_machine_type" {
  description = "Machine type for the compute instance."
  value       = var.machine_type
}

output "mgmt_nat_ip" {
  description = "External IP of the MGMT interface."
  value       = local.mgmt_nat_ip
}

output "wan_nat_ip" {
  description = "External IP of the WAN interface."
  value       = local.wan_nat_ip
}

output "mgmt_network" {
  description = "Self-link for the MGMT network of the compute instance."
  value       = local.network_interface.network
}

output "ssh_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "ssh_pub_key" {
  value     = tls_private_key.ssh_key.public_key_openssh
  sensitive = false
}