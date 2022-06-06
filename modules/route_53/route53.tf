/*
  Galit Udovik

  OpsSchool DevOps cource
  Application Load Balancer
*/

/*
resource "aws_route53_zone" "my_supernova_live" {
  name = "mysupernova.live"

  tags = {
    Name      = "Route53_hosted_zone_${var.name}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}
*/


data "aws_route53_zone" "hosted_zone_53" {
  name         = var.route53_host_zone_name
  private_zone = false
}

resource "aws_route53_record" "route_record" {
  zone_id = data.aws_route53_zone.hosted_zone_53.id
  name    = var.route53_record_name
  type    = "CNAME"
  ttl     = var.ttl
  records = var.route53_address_list_array
}
