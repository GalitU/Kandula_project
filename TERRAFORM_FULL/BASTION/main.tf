/*
  Galit Udovik
  OpsSchool DevOps cource
  Main file
*/

module "reguest_data" {
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
module "bastion_server" {
  source           = "../../modules/bastion"
  region           = var.region
  application_name = var.application_name
  application_task = var.application_task
  created_by       = var.created_by
  depends_on       = [module.reguest_data]
}
