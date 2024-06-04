
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

  # PING
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/10"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/10"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/10"]
  }
  # Allow all traffic to HTTP port 3000
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "TCP"
    cidr_blocks = ["${chomp(data.http.local_workstation_ip.body)}/32"]
  }
  # Allow all traffic to HTTP port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/10"]
  }
  # Allow all traffic to HTTP port 9090
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/10"]
  }
  # Allow all traffic to HTTP port 9091
  ingress {
    from_port   = 9091
    to_port     = 9091
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/10"]
  }
  # Allow all traffic to HTTP port 9093
  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/10"]
  }
  # Allow all traffic to HTTP port 9153
  ingress {
    from_port   = 9153
    to_port     = 9153
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/10"]
  }
  # Allow all traffic to HTTP port 9200
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/10"]
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

resource "aws_security_group_rule" "kube_ingress_ssh" {
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
