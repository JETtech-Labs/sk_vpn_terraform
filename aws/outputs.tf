locals {

  mgmt_elastic_ip   = aws_eip.mgmt_eip.public_ip
  wan_elastic_ip   = aws_eip.wan_eip.public_ip
  instance_ip = local.mgmt_elastic_ip
  
}

output "admin_url" {
  description = "Admin Url"
  value       = "https://${local.instance_ip}/"
}

output "instance_id" {
  description = "Instance ID for the compute instance."
  value       = aws_instance.instance.id
}

output "region" {
  description = "Region for the compute instance."
  value       = var.region
}

output "ami_id" {
  description = "AMI ID for the image used for the compute instance."
  value       = data.aws_ami.sk_ami.id
}

output "instance_type" {
  description = "Machine type for the compute instance."
  value       = var.instance_type
}

output "mgmt_elastic_ip" {
  description = "External IP of the MGMT interface."
  value       = local.mgmt_elastic_ip
}

output "wan_elastic_ip" {
  description = "External IP of the WAN interface."
  value       = local.wan_elastic_ip
}

output "vpc_id" {
  description = "VPC ID for the compute network of the compute instance."
  value       = aws_vpc.instance_vpc.id
}

output "ssh_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "ssh_pub_key" {
  value     = tls_private_key.ssh_key.public_key_openssh
  sensitive = false
}