/*
  Galit Udovik

  OpsSchool DevOps cource
  Configure all security groups
*/

# Security group for web server - HTTP
resource "aws_security_group" "sec_grp_http" {
  name        = "Sec. group for HTTP-${lower(var.application_name)}-${var.application_task}"
  description = "It will allows http traffic only"
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
    Name      = "Sec. group for HTTP-${lower(var.application_name)}-${var.application_task}"
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
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.sec_grp_http.id
}

# Security group for SSH server for SSH (for DB, for logic,for Web)
resource "aws_security_group" "sec_grp_ssh" {
  name        = "Sec. group for SSH-${lower(var.application_name)}-${var.application_task}"
  description = "It will allows SSH traffic"
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
    Name      = "Sec. group for SSH-${lower(var.application_name)}-${var.application_task}"
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

# Security group for special SSH server for SSH (for DB, for logic,for Web)
resource "aws_security_group" "special_sec_grp_ssh" {
  name        = "Sec. group for special SSH-${lower(var.application_name)}-${var.application_task}"
  description = "It will allows special SSH traffic"
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
    Name      = "Sec. group for special SSH-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}
resource "aws_security_group_rule" "special_ingress_ssh" {
  type        = "ingress"
  description = "Inbound SSH access from special address"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.special_cidr_block

  security_group_id = aws_security_group.special_sec_grp_ssh.id
}


# Security group for web server for HTTPs (for web)
resource "aws_security_group" "sec_grp_https" {
  name        = "Sec. group for HTTPS-${lower(var.application_name)}-${var.application_task}"
  description = "It will allows HTTPS traffic"
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
    Name      = "Sec. group for HTTPS-${lower(var.application_name)}-${var.application_task}"
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

  security_group_id = aws_security_group.sec_grp_https.id
}
