/*
  Galit Udovik

  OpsSchool DevOps cource
  Configure all security groups
*/

# Security group for web server - HTTP
resource "aws_security_group" "sec_grp_http" {
  name        = "SG_HTTP-${lower(var.application_name)}-${var.application_task}"
  description = "HTTP 80 sec group"
  vpc_id      = aws_vpc.vpc.id

  # Outbound access for any ports
  egress {
    description = "Outbound any access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Type      = "HTTP"
    Name      = "SG_HTTP-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_security_group_rule" "ingress_http" {
  type        = "ingress"
  description = "Inbound HTTP access"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  #cidr_blocks = ["0.0.0.0/0"]
  cidr_blocks = ["${chomp(data.http.local_workstation_ip.body)}/32"]

  security_group_id = aws_security_group.sec_grp_http.id
}

# Security group for SSH server for SSH (for DB, for logic,for Web)
resource "aws_security_group" "sec_grp_ssh" {
  name        = "SG_SSH-${lower(var.application_name)}-${var.application_task}"
  description = "SSH sec group 22"
  vpc_id      = aws_vpc.vpc.id

  # Outbound access for any ports
  egress {
    description = "Outbound any access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Type      = "SSH"
    Name      = "SG_SSH-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}
resource "aws_security_group_rule" "ingress_ssh" {
  type        = "ingress"
  description = "Inbound SSH access"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.sec_grp_ssh.id
}

#####  # Security group for special SSH server for SSH (for DB, for logic,for Web)
#####  resource "aws_security_group" "bastion_sec_grp_ssh" {
#####    name        = "SG_BastionSSH-${lower(var.application_name)}-${var.application_task}"
#####    description = "Bastion SSH from spec PC"
#####    vpc_id      = aws_vpc.vpc.id
#####
#####    # Outbound access for any ports
#####    egress {
#####      description = "Outbound access to special address"
#####      from_port   = 0
#####      to_port     = 0
#####      protocol    = "-1"
#####      cidr_blocks = ["0.0.0.0/0"]
#####    }
#####
#####    tags = {
#####      Type      = "Bastion"
#####      Name      = "SG_BastionSSH-${lower(var.application_name)}-${var.application_task}"
#####      App_name  = var.application_name
#####      Task      = var.application_task
#####      Owner     = var.application_owner
#####      CreatedBy = var.created_by
#####    }
#####  }
#####
#####  data "http" "local_workstation_ip" {
#####    url = "http://ipv4.icanhazip.com"
#####  }
#####
#####  resource "aws_security_group_rule" "special_ingress_ssh" {
#####    type        = "ingress"
#####    description = "Inbound SSH access from special address"
#####    from_port   = 22
#####    to_port     = 22
#####    protocol    = "tcp"
#####    cidr_blocks = ["${chomp(data.http.local_workstation_ip.body)}/32"]
#####
#####    security_group_id = aws_security_group.bastion_sec_grp_ssh.id
#####  }


# Security group for web server for HTTPs (for web)
resource "aws_security_group" "sec_grp_https" {
  name        = "SG_HTTPS-${lower(var.application_name)}-${var.application_task}"
  description = "HTTPS sec.group 443"
  vpc_id      = aws_vpc.vpc.id

  # Outbound access for any ports
  egress {
    description = "Outbound any access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Type      = "HTTPS"
    Name      = "SG_HTTPS-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_security_group_rule" "ingress_https" {
  type        = "ingress"
  description = "Inbound HTTPS access"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  #cidr_blocks = ["${chomp(data.http.local_workstation_ip.body)}/32", "10.0.0.0/10"]
  security_group_id = aws_security_group.sec_grp_https.id
}
