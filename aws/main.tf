provider "aws" {
  region=var.region
}


locals {
  mgmt_elastic_ip_name= var.mgmt_public_ip != "" ? var.mgmt_public_ip : "${var.aws_instance_name}-mgmt-ip"
  wan_elastic_ip_name= var.wan_public_ip != "" ? var.wan_public_ip : "${var.aws_instance_name}-wan-ip"
}


data "aws_ami" "sk_ami" {
  most_recent = true
  owners = ["self", "679593333241"]
  filter {
    name   = "product-code"
    values = [var.product_id]
  }
}

resource "aws_instance" "instance" {
  ami = data.aws_ami.sk_ami.id
  instance_type = var.instance_type
  key_name = aws_key_pair.aws_ssh_key_pair.key_name
  tags = {
    Name = var.aws_instance_name
  }

  network_interface {
    network_interface_id = aws_network_interface.mgmt_nic.id
    device_index = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.wan_nic.id
    device_index = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.lan_nic.id
    device_index = 2
  }

}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.instance_vpc.id
}

resource "aws_route_table" "rt_default" {
  vpc_id = aws_vpc.instance_vpc.id
}

resource "aws_route_table" "lan_rt" {
  vpc_id = aws_vpc.instance_vpc.id
}

resource "aws_route" "route_default" {
  route_table_id         = aws_route_table.rt_default.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}


resource "aws_route_table_association" "mgmt_igw_assoc" {
  subnet_id      = aws_subnet.mgmt_subnet.id
  route_table_id = aws_route_table.rt_default.id
}

resource "aws_route_table_association" "wan_igw_assoc" {
  subnet_id      = aws_subnet.wan_subnet.id
  route_table_id = aws_route_table.rt_default.id
}

resource "aws_route_table_association" "lan_rt_assoc" {
  subnet_id      = aws_subnet.lan_subnet.id
  route_table_id = aws_route_table.lan_rt.id
}

resource "aws_main_route_table_association" "default_igw_assoc" {
  vpc_id         = aws_vpc.instance_vpc.id
  route_table_id = aws_route_table.rt_default.id
}

resource "aws_vpc" instance_vpc {
 cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}


resource "aws_subnet" "mgmt_subnet" {
  vpc_id            = aws_vpc.instance_vpc.id
  cidr_block        = var.mgmt_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = var.mgmt_subnet
  }
}

resource "aws_subnet" "wan_subnet" {
  vpc_id            = aws_vpc.instance_vpc.id
  cidr_block        = var.wan_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = var.wan_subnet
  }
}

resource "aws_subnet" "lan_subnet" {
  vpc_id            = aws_vpc.instance_vpc.id
  cidr_block        = var.lan_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = var.lan_subnet
  }
}


resource "aws_network_interface" "mgmt_nic" {
  subnet_id            = aws_subnet.mgmt_subnet.id
  security_groups = [aws_security_group.allow_https.id, aws_security_group.allow_ssh.id]
  
  tags = {
    Name = var.mgmt_nic_name
  }

}

resource "aws_network_interface" "wan_nic" {
  subnet_id            = aws_subnet.wan_subnet.id
  security_groups = [aws_security_group.allow_all.id]
  source_dest_check = false

  tags = {
    Name = var.wan_nic_name
  }


}

resource "aws_network_interface" "lan_nic" {
  subnet_id            = aws_subnet.lan_subnet.id
  security_groups = [aws_security_group.allow_all.id]
  source_dest_check = false

  tags = {
    Name = var.lan_nic_name
  }

}

/*
resource "aws_network_interface_sg_attachment" "mgmt_sg_attachment_tls" {
  security_group_id    = aws_security_group.allow_https.id
  network_interface_id = aws_network_interface.mgmt_nic.id
}

resource "aws_network_interface_sg_attachment" "mgmt_sg_attachment_ssh" {
  security_group_id    = aws_security_group.allow_ssh.id
  network_interface_id = aws_network_interface.mgmt_nic.id
}
*/

resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.instance_vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_https"
  }
}

resource "aws_eip" "mgmt_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.mgmt_nic.id

  tags = {
    Name = local.mgmt_elastic_ip_name
  }
}

resource "aws_eip" "wan_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.wan_nic.id

  tags = {
    Name = local.wan_elastic_ip_name
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.instance_vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.instance_vpc.id

  ingress {
    description = "All from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws_ssh_key_pair" {
  key_name   = var.key_name == "" ? "${var.aws_instance_name}-ssh-key" : var.key_name
  public_key = var.ssh_pub_key_file == "create" ? tls_private_key.ssh_key.public_key_openssh : file(var.ssh_pub_key_file)
}
