/*
  Galit Udovik

  OpsSchool DevOps cource
  Received module.data from AWS
*/

/* VPC info */
output "vpc_id" {
  value = module.data.vpc_id
}
output "bastion_subnets" {
  value = [module.data.bastion_subnets_ids]
}
output "master_subnets" {
  value = [module.data.master_subnets_ids]
}
output "describe_kandula_mid_iam_instance_profile" {
  value = module.data.describe_kandula_mid_iam_instance_profile
}
output "pub_subnets" {
  value = module.data.pub_subnets_ids
}
output "pvt_subnets" {
  value = module.data.pvt_subnets_ids
}
output "sec_grp_http" {
  value = module.data.sec_grp_http_ids
}
output "sec_grp_https" {
  value = module.data.sec_grp_https_ids
}
output "sec_grp_ssh" {
  value = module.data.sec_grp_ssh_ids
}
output "sec_grp_consul" {
  value = module.data.sec_grp_consul_ids
}
output "sec_grp_jenkins" {
  value = module.data.sec_grp_jenkins_ids
}
output "sec_grp_bastion" {
  value = module.data.sec_grp_bastion_ids
}
output "key_pair_master" {
  value = join("_", ["Key", "Master", var.application_task, var.application_name])
}
output "key_pair_bastion" {
  value = join("_", ["Key", "Bastion", var.application_task, var.application_name])
}
output "key_pair_webservers" {
  value = join("_", ["Key", "WebServers", var.application_task, var.application_name])
}
output "key_pair_consul" {
  value = join("_", ["Key", "Consul", var.application_task, var.application_name])
}
