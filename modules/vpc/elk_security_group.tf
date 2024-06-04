/*
  Galit Udovik

  OpsSchool DevOps cource
  Configure all security groups
*/

resource "aws_security_group" "elk_server" {
  name   = "SG_ELK-${lower(var.application_name)}-${var.application_task}"
  vpc_id = aws_vpc.vpc.id
  ## Incoming roles
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }
  ingress {
    from_port       = 5601
    to_port         = 5601
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    #security_groups = [var.alb1_security_group_id]
    description     = "For Kibana UI"
  }
  ingress {
    from_port       = 5044
    to_port         = 5044
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    #security_groups = [var.alb1_security_group_id]
    description     = "LogStash"
  }
  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "For ELK internal"
  }
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "For ELK UI"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Type      = "ELK"
    Name      = "SG_EKL-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}
