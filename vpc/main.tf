provider "aws" {
  region     = "${var.region}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "mynginx_main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.vpc_tag}"
  }
}

resource "aws_internet_gateway" "mynginx_gw" {
  vpc_id = "${aws_vpc.mynginx_main.id}"

  tags = {
    Name = "${var.igw_tag}"
  }
}

resource "aws_route_table" "mynginx_public" {
  vpc_id = "${aws_vpc.mynginx_main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.mynginx_gw.id}"
  }

  tags = {
    Name = "Public"
  }
}

resource "aws_route_table" "mynginx_private" {
  vpc_id = "${aws_vpc.mynginx_main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.mynginx_gw.id}"
  }

  tags = {
    Name = "Private"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = 3
  cidr_block              = "${var.public_cidrs[count.index]}"
  vpc_id                  = "${aws_vpc.mynginx_main.id}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.public_subnet_tag}.${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = 3
  cidr_block              = "${var.private_cidrs[count.index]}"
  vpc_id                  = "${aws_vpc.mynginx_main.id}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.private_subnet_tag}.${count.index + 1}"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  count          = 3
  subnet_id      = "${aws_subnet.public_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.mynginx_public.id}"
  depends_on     = [aws_route_table.mynginx_public, aws_subnet.public_subnet]
}

resource "aws_route_table_association" "private_subnet_assoc" {
  count          = 3
  subnet_id      = "${aws_subnet.private_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.mynginx_private.id}"
  depends_on     = [aws_route_table.mynginx_public, aws_subnet.private_subnet]
}

resource "aws_security_group" "mynginx_sg" {
  name        = "mynginx-sg"
  description = "Allow ssh inbound traffic"
  vpc_id      = "${aws_vpc.mynginx_main.id}"

  tags = {
    Name = "Allow_ssh_http"
  }
}

resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.mynginx_sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["10.0.0.0/16"]
}

resource "aws_security_group_rule" "http_inbound_access" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.mynginx_sg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["10.0.0.0/16"]
}

resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.mynginx_sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["10.0.0.0/16"]
}

