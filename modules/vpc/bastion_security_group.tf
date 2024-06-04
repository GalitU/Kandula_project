
# Security group for special SSH server for SSH (for DB, for logic,for Web)

resource "aws_security_group" "bastion_sec_grp_ssh" {
  name        = "SG_Bastion_s_SSH-${lower(var.application_name)}-${var.application_task}"
  description = "Bastion SSH from spec PC"
  vpc_id      = aws_vpc.vpc.id

  # Outbound access for any ports
  egress {
    description = "Outbound access to special address"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Type      = "SSH"
    Name      = "SG_Bastion_SSH-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

data "http" "local_workstation_ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type        = "ingress"
  description = "Inbound SSH access from my PC station address only"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${chomp(data.http.local_workstation_ip.body)}/32"]

  security_group_id = aws_security_group.bastion_sec_grp_ssh.id
}

resource "aws_security_group_rule" "bastion_ingress_ssh_jenkins" {
  type        = "ingress"
  description = "Inbound SSH access for any EC2 inside private subnets"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/21"]

  security_group_id = aws_security_group.bastion_sec_grp_ssh.id
}
