/*
  Galit Udovik

  OpsSchool DevOps cource
  Output data
*/

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}
output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}
output "data_aws_region" {
  value = data.aws_region.current.name
}
output "data_aws_region_description" {
  value = data.aws_region.current.description
}


/* Roles */
output "role" {
  value = module.gu_iam_roles_describe.role
}
output "role_policy" {
  value = module.gu_iam_roles_describe.role_policy
}

output "iam_role_name" {
  value = module.gu_iam_roles_describe.iam_role_name
}

/* VPC info */
output "vpc_id" {
  value = module.gu_reguest_data.vpc_id
}
output "cosul_alb_dns" {
  value = module.gu_elk_server_load_balancers.alb_dns
}
output "elk_http_address" {
  value = "https://${module.gu_route53.hosted_zone_record_fqdn}"
}
/* elk server output */
output "ec2_elk_servers_arn" {
  value = module.gu_ec2_elk.ec2_servers_arn
}
output "ec2_elk_servers_id" {
  value = module.gu_ec2_elk.ec2_servers_id
}
output "ec2_elk_servers_dns" {
  value = module.gu_ec2_elk.ec2_servers_dns
}
output "ec2_elk_servers_private_ip" {
  value = module.gu_ec2_elk.ec2_servers_private_ips
}
output "ec2_servers_private_ips_arr" {
  value = module.gu_ec2_elk.ec2_servers_private_ips_arr
}
