output "hosted_zone_53_id" {
  value = data.aws_route53_zone.hosted_zone_53.id
}
output "hosted_zone_53_name" {
  value = data.aws_route53_zone.hosted_zone_53.name
}
output "hosted_zone_53_name_servers" {
  value = data.aws_route53_zone.hosted_zone_53.name_servers
}
output "hosted_zone_record_fqdn" {
  value = aws_route53_record.route_record.fqdn
}
