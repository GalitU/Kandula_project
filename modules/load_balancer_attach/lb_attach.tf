/*
  Galit Udovik

  OpsSchool DevOps cource
  Application Load Balancer
*/

locals {
  alb_type = "${lower(var.application_name)}-${var.application_task}"
}

resource "aws_lb_target_group" "alb-target" {
  count    = length(var.listener_ports)
  name     = "LB-tgrp-${var.listener_ports[count.index]}-${var.lb_purpose}"
  port     = var.listener_ports[count.index]
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    path    = "/"
    port    = var.listener_ports[count.index]
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 60
  }

  tags = {
    Name      = "LB_target_group_${var.listener_ports[count.index]}_${var.lb_purpose}_${local.alb_type}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_lb_listener" "alb-listener-https" {
  count             = length(var.listener_ports)
  load_balancer_arn = var.alb_arn
  port              = var.listener_ports[count.index]
  protocol          = var.listener_protocols[count.index]
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.aws_acm_certificate_id

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target[count.index].arn
  }
  tags = {
    Name      = "LB_listener_${var.lb_purpose}_${var.listener_ports[count.index]}_${var.listener_protocols[count.index]}_${local.alb_type}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_lb_target_group_attachment" "server-attach-group" {
  count            = length(var.listener_ports)
  target_group_arn = aws_lb_target_group.alb-target[count.index].arn
  target_id        = var.server_for_attach_to_lb
  port             = var.target_port
}
