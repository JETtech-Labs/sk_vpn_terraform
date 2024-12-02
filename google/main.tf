provider "google" {
  project = var.project_id
}


locals {
  nets = ["mgmt", "wan", "lan"]

  // make local variable for external IPs - where we only use the name if not "EPHEMERAL" and not "NONE"
  pub_ips = [for ip in var.external_ips : ip if ip != "EPHEMERAL" && ip != "NONE"]

  network_interfaces = [ for i, net in local.nets : {
    network     = local.nets[i] == "mgmt" ? google_compute_network.mgmt-vpc.self_link : local.nets[i] == "wan" ? google_compute_network.wan-vpc.self_link : google_compute_network.lan-vpc.self_link 
    subnetwork  = local.nets[i] == "mgmt" ? google_compute_subnetwork.mgmt-subnet.self_link : local.nets[i] == "wan" ? google_compute_subnetwork.wan-subnet.self_link : google_compute_subnetwork.lan-subnet.self_link 
    external_ip = length(var.external_ips) > i ? element(var.external_ips, i) : "NONE"
    index = i
    }
  ]
  // Region -> remove the letter following the last '-' from the zone string
  // e.g. us-central1-a -> us-central1
  region = join("-", [split("-", var.zone)[0], split("-", var.zone)[1]])

  ssh_pub_key_content = var.ssh_pub_key_file == "create" ? tls_private_key.ssh_key.public_key_openssh : file(var.ssh_pub_key_file)

  metadata = {
    google-logging-enable = "0"
    google-monitoring-enable = "0"
    sshKeys ="sk_admin:${local.ssh_pub_key_content}"
  }
}

resource "google_compute_instance" "instance" {
  name = "${var.goog_cm_deployment_name}"
  machine_type = var.machine_type
  zone = var.zone

  tags = ["${var.goog_cm_deployment_name}-deployment"]

  boot_disk {
    device_name = "autogen-vm-tmpl-boot-disk"

    initialize_params {
      size = var.boot_disk_size
      type = var.boot_disk_type
      image = var.source_image
    }
  }

  can_ip_forward = var.ip_forward

  metadata = local.metadata

  dynamic "network_interface" {
    for_each = local.network_interfaces
    content {
      network = network_interface.value.network 
      subnetwork = network_interface.value.subnetwork
      stack_type="IPV4_ONLY"
      nic_type="GVNIC"

      dynamic "access_config" {
        for_each = network_interface.value.external_ip == "NONE" ? [] : [1]
        content {
          nat_ip = network_interface.value.external_ip == "EPHEMERAL" ? null : network_interface.value.index == 0 ? google_compute_address.mgmt-public-ip.address : network_interface.value.index == 1 ? google_compute_address.wan-public-ip.address : null
        }
      }
    }
  }

  service_account {
    email = "default"
    scopes = compact([
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ])
  }
}

resource "google_compute_firewall" tcp_22 {
  count = var.enable_tcp_22 ? 1 : 0

  name = "${var.goog_cm_deployment_name}-tcp-22"
  network = google_compute_network.mgmt-vpc.self_link

  allow {
    ports = ["22"]
    protocol = "tcp"
  }

  source_ranges =  compact([for range in split(",", var.tcp_22_source_ranges) : trimspace(range)])

  target_tags = ["${var.goog_cm_deployment_name}-deployment"]
}

resource "google_compute_firewall" tcp_443 {
  count = var.enable_tcp_443 ? 1 : 0

  name = "${var.goog_cm_deployment_name}-tcp-443"
  network = google_compute_network.mgmt-vpc.self_link

  allow {
    ports = ["443"]
    protocol = "tcp"
  }

  source_ranges =  compact([for range in split(",", var.tcp_443_source_ranges) : trimspace(range)])

  target_tags = ["${var.goog_cm_deployment_name}-deployment"]
}


resource "google_compute_address" mgmt-public-ip {
  name = length(local.pub_ips)>0 && local.pub_ips[0] != "mgmt-public-ip" ? local.pub_ips[0] : "${var.goog_cm_deployment_name}-mgmt-ip"
  region = local.region
  address_type = "EXTERNAL"
}

resource "google_compute_address" wan-public-ip {
  name = length(local.pub_ips)>1 && local.pub_ips[1] != "wan-public-ip" ? local.pub_ips[1] : "${var.goog_cm_deployment_name}-wan-ip"
  region = local.region
  address_type = "EXTERNAL"
}


resource "google_compute_network" mgmt-vpc {
  name  = var.mgmt_net == "" ? "${var.goog_cm_deployment_name}-mgmt-vpc" : "${var.mgmt_net}"
  auto_create_subnetworks = "false"
}

resource "google_compute_network" wan-vpc {
  name  = var.wan_net == "" ? "${var.goog_cm_deployment_name}-wan-vpc" : "${var.wan_net}"
  auto_create_subnetworks = "false"
}

resource "google_compute_network" lan-vpc {
  name  = var.lan_net == "" ? "${var.goog_cm_deployment_name}-lan-vpc" : "${var.lan_net}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" mgmt-subnet {
  name          = var.mgmt_subnet == "" ? "${var.goog_cm_deployment_name}-mgmt-subnet" : "${var.mgmt_subnet}"
  ip_cidr_range = "${var.mgmt_cidr}"
  region        = local.region
  network       = google_compute_network.mgmt-vpc.self_link
}

resource "google_compute_subnetwork" wan-subnet {
  name          = var.wan_subnet == "" ? "${var.goog_cm_deployment_name}-wan-subnet" : "${var.wan_subnet}"
  ip_cidr_range = "${var.wan_cidr}"
  region        = local.region
  network       = google_compute_network.wan-vpc.self_link
}

resource "google_compute_subnetwork" lan-subnet {
  name          = var.lan_subnet == "" ? "${var.goog_cm_deployment_name}-lan-subnet" : "${var.lan_subnet}"
  ip_cidr_range = "${var.lan_cidr}"
  region        = local.region
  network       = google_compute_network.lan-vpc.self_link
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
