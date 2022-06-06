/*
  Galit Udovik

  OpsSchool DevOps cource
  Configure all consul security groups
*/
locals {
  consul_cidr_block = concat(var.cidr_block_pvt, var.cidr_block_pub)
}

# One security group for Consul Server UI which includes all relevant rules
resource "aws_security_group" "consul_sg_server_ui" {
  name        = "SG_Consul-UI-${lower(var.application_name)}-${var.application_task}"
  description = "Consul Sec. group for UI-${lower(var.application_name)}-${var.application_task}"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Type      = "Consul"
    Name      = "SG_Consul-UI-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

# One security group for Consul which includes all relevant rules
resource "aws_security_group" "consul_sg" {
  name        = "SG_Consul-${lower(var.application_name)}-${var.application_task}"
  description = "Consul Sec. group-${lower(var.application_name)}-${var.application_task}"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Type      = "Consul"
    Name      = "SG_Consul-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}


# Serf LAN TCP 8301. Usable for gossip
resource "aws_security_group_rule" "serf_tcp_rpc_rule" {
  security_group_id = aws_security_group.consul_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8300
  to_port           = 8300
  cidr_blocks       = local.consul_cidr_block
}


# Serf LAN TCP 8301. Usable for gossip
resource "aws_security_group_rule" "serf_tcp_lan_sec_rule" {
  security_group_id = aws_security_group.consul_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8301
  to_port           = 8301
  cidr_blocks       = local.consul_cidr_block
}

# Serf LAN TCP 8301. Usable for gossip
resource "aws_security_group_rule" "serf_udp_lan_sec_rule" {
  security_group_id = aws_security_group.consul_sg.id
  type              = "ingress"
  protocol          = "udp"
  from_port         = 8301
  to_port           = 8301
  cidr_blocks       = local.consul_cidr_block
}

# HTTP API - TCP 8500, default. Useful by HTTP API agents request only for servers
resource "aws_security_group_rule" "http_api_sec_rule" {
  security_group_id = aws_security_group.consul_sg_server_ui.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8500
  to_port           = 8500
  cidr_blocks       = ["0.0.0.0/0"] # TODO - change to - [var.cidr_block_pvt, var.cidr_block_pub]
}

# DNS Interface - TCP 8600. Useful for resolve DNS consul queries
resource "aws_security_group_rule" "dns_tcp_sec_rule" {
  security_group_id = aws_security_group.consul_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8600
  to_port           = 8600
  cidr_blocks       = local.consul_cidr_block
}

# DNS Interface - UDP 8600. Useful for resolve DNS consul queries
resource "aws_security_group_rule" "dns_udp_sec_rule" {
  security_group_id = aws_security_group.consul_sg.id
  type              = "ingress"
  protocol          = "udp"
  from_port         = 8600
  to_port           = 8600
  cidr_blocks       = local.consul_cidr_block
}

# All TCP outbound traffic
resource "aws_security_group_rule" "all_outbound_tcp_ui" {
  security_group_id = aws_security_group.consul_sg_server_ui.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}

# All UDP outbound traffic
resource "aws_security_group_rule" "all_outbound_udp_ui" {
  security_group_id = aws_security_group.consul_sg_server_ui.id
  type              = "egress"
  protocol          = "udp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}

# All TCP outbound traffic
resource "aws_security_group_rule" "all_outbound_tcp" {
  security_group_id = aws_security_group.consul_sg.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}

# All UDP outbound traffic
resource "aws_security_group_rule" "all_outbound_udp" {
  security_group_id = aws_security_group.consul_sg.id
  type              = "egress"
  protocol          = "udp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}
