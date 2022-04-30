/*
  Galit Udovik

  OpsSchool DevOps cource
  Application Load Balancer
*/

locals {
  alb_type = "${lower(var.application_name)}-${var.application_task}"
}

resource "aws_lb" "alb" {
  name     = "LB-${var.lb_purpose}-${local.alb_type}"
  internal = var.internal
  subnets  = var.subnets

  security_groups    = var.lb_sec_group_array
  load_balancer_type = "application"
  idle_timeout       = var.idle_timeout

  tags = {
    Name      = "LB_${var.lb_purpose}_${local.alb_type}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_lb_listener" "alb-listener" {
  count             = length(var.listener_ports)
  load_balancer_arn = aws_lb.alb.arn
  port              = var.listener_ports[count.index]
  protocol          = var.listener_protocols[count.index]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target.arn
  }
  tags = {
    Name      = "LB_listener_${var.lb_purpose}_${var.listener_ports[count.index]}_${var.listener_protocols[count.index]}_${local.alb_type}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_lb_target_group" "alb-target" {
  name     = "LB-tgrp-${var.lb_purpose}-${local.alb_type}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    path    = "/"
  }

  tags = {
    Name      = "LB_target_group_${var.lb_purpose}_${local.alb_type}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_lb_target_group_attachment" "server-attach-group" {
  count            = length(var.servers_for_attach_to_lb)
  target_group_arn = aws_lb_target_group.alb-target.arn
  target_id        = var.servers_for_attach_to_lb[count.index]
  port             = var.target_port
}

output "alb_dns" {
  value = aws_lb.alb.dns_name
}
