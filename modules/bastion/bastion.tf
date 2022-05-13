/*
  Galit Udovik
  OpsSchool DevOps cource
  Main file
*/

/*
module "key_credentials_bastion" {
  source           = "../../modules/key_credentials"
  application_task = var.application_task
  application_name = var.application_name
  created_by       = var.created_by
  root_directory   = abspath(path.module)
  key_purpose      = "Bastion"
}

module data_get {
  source                      = "../../modules/ec2_servers"
}
*/


module "iam_roles_describe" {
  source                    = "../roles"
  access_policy_description = "Describe"
  role_policy_type          = file("${path.module}/../roles/policies/assume_role.json")
  access_policy_type        = file("${path.module}/../roles/policies/describe_instances.json")
  purpose                   = "Bastion"
  application_name          = var.application_name
  application_task          = var.application_task
  created_by                = var.created_by
}

module "reguest_data" {
  source           = "../data"
  region           = var.region
  application_name = var.application_name
  application_task = var.application_task
  created_by       = var.created_by
  vpc_name         = join("-", ["VPC", lower(var.application_name), var.application_task])
}

module "ec2_bastion_server" {
  source                      = "../ec2_servers"
  region                      = var.region
  ec2_instance_type           = var.ec2_instance_type
  ami                         = var.ami
  count_instances             = 1
  ec2_purpose                 = "Bastion"
  type_of_subnet              = "Public"
  subnet_association_tag      = "Bastion"
  ec2_sec_group_array         = concat([aws_security_group.bastion_sec_grp_ssh.id], module.reguest_data.sec_grp_consul_ids)
  access_key_name             = module.reguest_data.key_pair_bastion
  vpc_id                      = module.reguest_data.vpc_id
  ec2_OS                      = "Ubuntu"
  iam_instance_profile        = module.iam_roles_describe.iam_instance_profile
  user_data_file              = file("${path.module}/../scripts/bastion.sh")
  associate_public_ip_address = true
  application_name            = var.application_name
  application_task            = var.application_task
  created_by                  = var.created_by
  consul_prefix               = "ConsulAgent"
  consul_app_discovery_tag    = "Consul"
}
