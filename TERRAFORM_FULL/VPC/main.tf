/*
  Galit Udovik
  OpsSchool DevOps cource
  Main file
*/

locals {
  # Subnet purpose
  subnet_pvt_prefix_arr = ["Consul", "Consul", "Master", "Master", "WebServers", "WebServers"]
  subnet_pub_prefix_arr = ["Bastion", "General"]

  # CIDR per purpose
  subnet_pvt_cidr_arr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  subnet_pub_cidr_arr = ["10.0.31.0/24", "10.0.32.0/24"]
}

module "gu_vpc" {
  source = "../../modules/vpc"
  region                         = var.region
  cidr_block_pvt                 = local.subnet_pvt_cidr_arr
  cidr_block_pub                 = local.subnet_pub_cidr_arr
  subnet_pvt_prefix_template_arr = local.subnet_pvt_prefix_arr
  subnet_pub_prefix_template_arr = local.subnet_pub_prefix_arr
  application_name               = var.application_name
  application_task               = var.application_task
  created_by                     = var.created_by
}
