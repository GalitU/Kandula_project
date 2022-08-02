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

/* VPC info */
output "vpc_id" {
  value = module.gu_reguest_data.vpc_id
}
/* Bastion output */
output "bastion_server_arn" {
  value = module.gu_bastion_server.bastion_server_arn
}
output "bastion_server_id" {
  value = module.gu_bastion_server.bastion_server_id
}
output "bastion_server_dns" {
  value = module.gu_bastion_server.bastion_server_dns
}
output "bastion_server_private_ip" {
  value = module.gu_bastion_server.bastion_server_private_ip
}
output "bastion_server_public_ip" {
  value = module.gu_bastion_server.bastion_server_public_ip
}
