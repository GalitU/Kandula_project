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
  source                    = "../modules/roles"
  access_policy_description = "Describe"
  role_policy_type          = "sts:AssumeRole"
  access_policy_type        = "ec2:DescribeInstances"
  purpose                   = "Bastion"
  application_name          = var.application_name
  application_task          = var.application_task
  created_by                = var.created_by
}

module "reguest_data" {
  source           = "../modules/data"
  region           = var.region
  application_name = var.application_name
  application_task = var.application_task
  created_by       = var.created_by
  vpc_name         = join("-", ["VPC", lower(var.application_name), var.application_task])
}

module "ec2_bastion_server" {
  source                      = "../modules/ec2_servers"
  region                      = var.region
  ec2_instance_type           = var.ec2_instance_type
  ami                         = var.ami
  count_instances             = 1
  ec2_purpose                 = "Bastion1"
  type_of_subnet              = "Public"
  subnet_association_tag      = "Bastion"
  ec2_sec_group_array         = [aws_security_group.bastion_sec_grp_ssh.id] #module.reguest_data.sec_grp_bastion_ids
  access_key_name             = module.reguest_data.key_pair_bastion
  vpc_id                      = module.reguest_data.vpc_id
  ec2_OS                      = "Ubuntu"
  iam_instance_profile        = module.iam_roles_describe.iam_instance_profile
  user_data_file              = file("${path.module}/../modules/scripts/bastion.sh")
  associate_public_ip_address = true
  application_name            = var.application_name
  application_task            = var.application_task
  created_by                  = var.created_by
  consul_prefix               = ""
  consul_app_discovery_tag    = ""
}
