
locals {
  domain_name = "galitu.site"
}

data "aws_route53_zone" "hosted_zone_53" {
  name         = local.domain_name
  private_zone = false
}

resource "aws_acm_certificate" "compoze_acm" {
  domain_name       = "*.${local.domain_name}"
  validation_method = "DNS"

  tags = {
    Name      = "Cert_${local.domain_name}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.compoze_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone_53.id
}

resource "aws_acm_certificate_validation" "validation" {
  timeouts {
    create = "5m"
  }
  certificate_arn         = aws_acm_certificate.compoze_acm.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}
