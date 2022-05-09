/*
  Galit Udovik
  OpsSchool DevOps cource
  Main file
*/

module "data" {
  source                         = "../modules/data"
  region                         = var.region
  application_name               = var.application_name
  application_task               = var.application_task
  created_by                     = var.created_by
  vpc_name                       = join("-", ["VPC", lower(var.application_name), var.application_task]) 
}
