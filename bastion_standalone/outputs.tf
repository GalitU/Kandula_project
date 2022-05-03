/*
  Galit Udovik

  OpsSchool DevOps cource
  Output data
*/

output "data_aws_region" {
  value = var.region
}
/* VPC info */
output "vpc_id" {
  value = module.reguest_data.vpc_id
}
output "private_key_names" {
  value = join(", ",
    [
      module.reguest_data.key_pair_bastion
  ])
}
/* Bastion output */
output "ec2_bastion_server_arn" {
  value = module.ec2_bastion_server.ec2_servers_arn
}
output "ec2_bastion_server_id" {
  value = module.ec2_bastion_server.ec2_servers_id
}
output "ec2_bastion_server_dns" {
  value = module.ec2_bastion_server.ec2_servers_dns
}
output "ec2_bastion_server_private_ip" {
  value = module.ec2_bastion_server.ec2_servers_private_ips
}
output "ec2_bastion_server_public_ip" {
  value = module.ec2_bastion_server.ec2_servers_public_ips
}
