/*
  Galit Udovik

  OpsSchool DevOps cource
  Application Load Balancer
*/

locals {
  consul_alb_type = "${lower(var.application_name)}-${var.application_task}"
}

resource "aws_lb" "consul-alb" {
  name     = "LB-${var.consul_lb_purpose}-${local.consul_alb_type}"
  internal = var.internal
  subnets  = var.subnets

  security_groups    = var.lb_consul_sec_group_array
  load_balancer_type = "application"
  idle_timeout       = var.idle_timeout

  tags = {
    Name      = "LB_${var.consul_lb_purpose}_${local.consul_alb_type}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_lb_listener" "consul-alb-listener" {
  count             = length(var.consul_listener_ports)
  load_balancer_arn = aws_lb.consul-alb.arn
  port              = var.consul_listener_ports[count.index]
  protocol          = var.consul_listener_protocols[count.index]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul-alb-target.arn
  }
  tags = {
    Name      = "LB_listener_${var.consul_lb_purpose}_${var.consul_listener_ports[count.index]}_${var.consul_listener_protocols[count.index]}_${local.consul_alb_type}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_lb_target_group" "consul-alb-target" {
  name     = "LB-tgt-grp-${var.consul_lb_purpose}-${local.consul_alb_type}"
  port     = 8500
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    path    = "/"
  }

  tags = {
    Name      = "consul_lb_purpose_group_${var.consul_lb_purpose}_${local.consul_alb_type}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_lb_target_group_attachment" "consul_server_attach_group" {
  count            = length(var.consul_servers_for_attach_to_lb)
  target_group_arn = aws_lb_target_group.consul-alb-target.arn
  target_id        = var.consul_servers_for_attach_to_lb[count.index]
  port             = var.consul_target_port
}

output "cosul_alb_dns" {
  value = aws_lb.consul-alb.dns_name
}
