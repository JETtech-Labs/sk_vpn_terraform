variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "ssh_pub_key_file" {
  description = "The path to the SSH public key file to provide to the VM. 'create' will generate a new key."
  type        = string
  default     = "create"
}

// Marketplace requires this variable name to be declared
variable "goog_cm_deployment_name" {
  description = "The name of the deployment and VM instance."
  type        = string
}

variable "source_image" {
  description = "The image name for the disk for the VM instance."
  type        = string
  default     = "projects/jet-technology-labs-public/global/images/sk-vpn-prod-v2-3-1736356923"
}

variable "zone" {
  description = "The zone for the solution to be deployed."
  type        = string
  default     = "us-west1-b"
}

variable "machine_type" {
  description = "The machine type to create, e.g. c2-standard-8"
  type        = string
  default     = "c2-standard-8"
}

variable "boot_disk_type" {
  description = "The boot disk type for the VM instance."
  type        = string
  default     = "pd-standard"
}

variable "boot_disk_size" {
  description = "The boot disk size for the VM instance in GBs"
  type        = number
  default     = 10
}


variable "mgmt_net" {
  description = "The MGMT network name, if blank set using VM instance name."
  type        = string
  default     = ""
}

variable "wan_net" {
  description = "The WAN network name, if blank set using VM instance name."
  type        = string
  default     = ""
}

variable "lan_net" {
  description = "The LAN network name, if blank set using VM instance name."
  type        = string
  default     = ""
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

variable "external_ips" {
  description = "The external IPs assigned to the VM for public access."
  type        = list(string)
  default     = ["mgmt-public-ip","wan-public-ip","NONE"]
}

variable "ip_forward" {
  description = "Whether to allow sending and receiving of packets with non-matching source or destination IPs."
  type        = bool
  default     = true
}

variable "enable_tcp_22" {
  description = "Allow TCP port 22 traffic from the Internet"
  type        = bool
  default     = true
}

variable "tcp_22_source_ranges" {
  description = "Source IP ranges for TCP port 22 traffic"
  type        = string
  default     = ""
}

variable "enable_tcp_443" {
  description = "Allow HTTPS traffic from the Internet"
  type        = bool
  default     = true
}

variable "tcp_443_source_ranges" {
  description = "Source IP ranges for HTTPS traffic"
  type        = string
  default     = ""
}
