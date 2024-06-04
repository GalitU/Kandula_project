/*
  Galit Udovik
  OpsSchool DevOps cource
  Main file
*/

module "gu_key_credentials_consul" {
  source           = "../../modules/key_credentials"
  application_name = var.application_name
  application_task = var.application_task
  created_by       = var.created_by
  root_directory   = abspath(path.module)
  key_purpose      = "Consul"
}

module "gu_key_credentials_bastion" {
  source           = "../../modules/key_credentials"
  application_task = var.application_task
  application_name = var.application_name
  created_by       = var.created_by
  root_directory   = abspath(path.module)
  key_purpose      = "Bastion"
}

module "gu_key_credentials_master" {
  source           = "../../modules/key_credentials"
  application_task = var.application_task
  application_name = var.application_name
  created_by       = var.created_by
  root_directory   = abspath(path.module)
  key_purpose      = "Master"
}

module "gu_key_credentials_webserver" {
  source           = "../../modules/key_credentials"
  application_task = var.application_task
  application_name = var.application_name
  created_by       = var.created_by
  root_directory   = abspath(path.module)
  key_purpose      = "WebServers"
}
