/*
  Galit Udovik

  OpsSchool DevOps cource
  Application Load Balancer
*/

locals {
  ec2_alb_type = "${lower(var.application_name)}-${var.application_task}"
}

resource "aws_lb" "ec2-alb" {
  name     = "LB-${var.ec2_lb_purpose}-${local.ec2_alb_type}"
  internal = var.internal
  subnets  = var.subnets

  security_groups    = var.lb_ec2_sec_group_array
  load_balancer_type = "application"
  idle_timeout       = var.idle_timeout

  tags = {
    Name      = "LB_${var.ec2_lb_purpose}_${local.ec2_alb_type}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_lb_listener" "ec2-alb-listener" {
  count             = length(var.ec2_listener_ports)
  load_balancer_arn = aws_lb.ec2-alb.arn
  port              = var.ec2_listener_ports[count.index]
  protocol          = var.ec2_listener_protocols[count.index]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2-alb-target.arn
  }
  tags = {
    Name      = "LB_listener_${var.ec2_lb_purpose}_${var.ec2_listener_ports[count.index]}_${var.ec2_listener_protocols[count.index]}_${local.ec2_alb_type}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_lb_target_group" "ec2-alb-target" {
  name     = "LB-tgrp-${var.ec2_lb_purpose}-${local.ec2_alb_type}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    path    = "/"
  }

  tags = {
    Name      = "LB_target_group_${var.ec2_lb_purpose}_${local.ec2_alb_type}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_lb_target_group_attachment" "ec2-server-attach-group" {
  count            = length(var.ec2_servers_for_attach_to_lb)
  target_group_arn = aws_lb_target_group.ec2-alb-target.arn
  target_id        = var.ec2_servers_for_attach_to_lb[count.index]
  port             = var.ec2_target_port
}

output "ec2_alb_dns" {
  value = aws_lb.ec2-alb.dns_name
}
