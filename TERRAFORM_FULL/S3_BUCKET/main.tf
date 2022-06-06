/*
  Galit Udovik
  OpsSchool DevOps cource
  Main file
*/

locals {
  root_path                          = abspath(path.module)
  assume_policy_file_path            = "${local.root_path}/../../modules/roles/policies/assume_role.json"
  describe_server_access_policy_file = "${local.root_path}/../../modules/roles/policies/describe_instances.json"
}

module "iam_roles_describe" {
  source                    = "../../modules/roles"
  access_policy_description = "Describe"
  role_policy_type          = file(local.assume_policy_file_path)
  access_policy_type        = file(local.describe_server_access_policy_file)
  purpose                   = "S3_bucket"
  application_name          = var.application_name
  application_task          = var.application_task
  created_by                = var.created_by
}

module "s3_bucket" {
  source           = "../../modules/s3"
  application_name = var.application_name
  application_task = var.application_task
  created_by       = var.created_by
  ec2_role = module.iam_roles_describe.role
  ec2_role_assign_for = "S3_bucket"
}
