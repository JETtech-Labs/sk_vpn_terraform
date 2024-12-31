variable "region" {
  description = "The Region in which to provision resources."
  type        = string
  default     = "us-west-2"
}

variable "availability_zone" {
  description = "The Availability Zone in which to provision resources."
  type        = string
  default     = "us-west-2a"
}

variable "ssh_pub_key_file" {
  description = "The path to the SSH public key file to provide to the VM. 'create' will generate a new key."
  type        = string
  default     = "create"
}

variable "key_name" {
  description = "The the SSH key name to use."
  type        = string
  default     = ""
}


variable "aws_instance_name" {
  description = "The name of the deployment and VM instance."
  type        = string
  default     = "aws-securekey-vm"
}

variable "vpc_name" {
  description = "The VPC to launch the instance into (default is the default VPC)"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "The VPC CIDR to use"
  type        = string
  default     = "10.0.0.0/16"
}

variable "product_id" {
  description = "The product ID for the deployment."
  type        = string
  default     = "/aws/service/marketplace/prod-7anczd5r647ng/v2.2"
}

variable "instance_type" {
  description = "The instance type to create"
  type        = string
  default     = "c6in.2xlarge"
}


variable "mgmt_subnet" {
  description = "The MGMT subnet name, if blank set using VM instance name."
  type        = string
  default     = ""
}

variable "wan_subnet" {
  description = "The WAN subnet name, if blank set using VM instance name."
  type        = string
  default     = ""
}

variable "lan_subnet" {
  description = "The LAN subnet name, if blank set using VM instance name."
  type        = string
  default     = ""
}

variable "mgmt_cidr" {
  description = "The private subnet for the MGMT network."
  type        = string
  default     = "10.0.2.0/24"
}

variable "wan_cidr" {
  description = "The private subnet for the WAN network."
  type        =string
  default     = "10.0.0.0/24"
}

variable "lan_cidr" {
  description = "The private subnet for the LAN network."
  type        = string
  default     = "10.0.1.0/24"
}

variable "mgmt_public_ip" {
  description = "The Elastic IP assigned to the Management Interface for public access."
  type        = string
  default     = ""
}

variable "wan_public_ip" {
  description = "The Elastic IP assigned to the WAN Interface for public access."
  type        = string
  default     = ""
}

variable "mgmt_nic_name" {
  description = "The MGMT network interface name."
  type        = string
  default     = ""
}

variable "wan_nic_name" {
  description = "The WAN network interface nam."
  type        = string
  default     = ""
}

variable "lan_nic_name" {
  description = "The LAN network interface name."
  type        = string
  default     = ""
}


