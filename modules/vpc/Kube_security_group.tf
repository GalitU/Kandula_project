
/*
  Galit Udovik

  OpsSchool DevOps cource
  Configure all security groups
*/

# Security group for Kube - HTTP
resource "aws_security_group" "kubernetes_sec_grp_http" {
  name        = "SG_Kube_worker-${lower(var.application_name)}-${var.application_task}"
  description = "Kubernetis mngm. sec. group"
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
    Type      = "Kubernetes"
    Name      = "SG_Kube_worker-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_security_group_rule" "kube_ingress_http" {
  type        = "ingress"
  description = "Inbound HTTP access"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]

  security_group_id = aws_security_group.kubernetes_sec_grp_http.id
}
