/*
  Galit Udovik
  OpsSchool DevOps cource
  Main file
*/
module "gu_reguest_data" {
  source                 = "../../modules/data"
  region                 = var.region
  application_name       = var.application_name
  application_task       = var.application_task
  created_by             = var.created_by
  vpc_name               = join("-", ["VPC", lower(var.application_name), var.application_task])
  route53_host_zone_name = "galitu.site"
}

#####################################################################################################
/* Ansible server */
module "gu_bastion_server" {
  source = "../../modules/bastion"
  region = var.region
  ec2_sec_group_array = concat(module.gu_reguest_data.sec_grp_bastion_ids,
    module.gu_reguest_data.sec_grp_consul_ids,
  module.gu_reguest_data.sec_grp_node_exporter)
  application_name = var.application_name
  application_task = var.application_task
  created_by       = var.created_by
  depends_on       = [module.gu_reguest_data]
  ami              = var.ami
}
