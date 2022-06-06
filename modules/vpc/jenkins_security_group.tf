/*
  Galit Udovik

  OpsSchool DevOps cource
  Configure all security groups
*/

# Security group for web server - HTTP
resource "aws_security_group" "jenkins_sec_grp_http" {
  name        = "SG_Jenkins-${lower(var.application_name)}-${var.application_task}"
  description = "Jenkins sec. group"
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
    Type      = "Jenkins"
    Name      = "SG_Jenkins-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_security_group_rule" "jenkins_ingress_http" {
  type        = "ingress"
  description = "Inbound HTTP access"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.jenkins_sec_grp_http.id
}
