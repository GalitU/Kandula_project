/*
  Galit Udovik
  OpsSchool DevOps cource
  Main file
*/

locals {
  root_path                         = abspath(path.module)
  assume_policy_file_path           = "${local.root_path}/../../modules/roles/policies/assume_role.json"
  jenkins_server_access_policy_file = "${local.root_path}/../../modules/roles/policies/jenkins_server_policy.json"
  jenkins_agent_access_policy_file  = "${local.root_path}/../../modules/roles/policies/jenkins_agents_policy.json"
}

module "iam_roles_describe_jenkins_server" {
  source                    = "../../modules/roles"
  access_policy_description = "Describe"
  role_policy_type          = file(local.assume_policy_file_path)
  access_policy_type        = file(local.jenkins_server_access_policy_file)
  purpose                   = "JenkinsSrv"
  application_name          = var.application_name
  application_task          = var.application_task
  created_by                = var.created_by
}

module "iam_roles_describe_jenkins_agent" {
  source                    = "../../modules/roles"
  access_policy_description = "Describe"
  role_policy_type          = file(local.assume_policy_file_path)
  access_policy_type        = file(local.jenkins_agent_access_policy_file)
  purpose                   = "JenkinsAgent"
  application_name          = var.application_name
  application_task          = var.application_task
  created_by                = var.created_by
}

module "reguest_data" {
  source           = "../../modules/data"
  region           = var.region
  application_name = var.application_name
  application_task = var.application_task
  created_by       = var.created_by
  vpc_name         = join("-", ["VPC", lower(var.application_name), var.application_task])
}

data "aws_instance" "bastion" {
  instance_tags = {
    Purpose  = "Bastion"
    Task     = var.application_task
    App_name = var.application_name
  }
  filter {
    name   = "vpc-id"
    values = [module.reguest_data.vpc_id]
  }
}

locals {
  abs_path_to_keys    = abspath(path.module)
  master_key          = module.reguest_data.key_pair_master
  bastion_key         = module.reguest_data.key_pair_bastion
  path_to_keys        = "${local.abs_path_to_keys}/../KEYS/"
  path_to_master_key  = "${local.abs_path_to_keys}/../KEYS/${local.master_key}.pem"
  path_to_bastion_key = "${local.abs_path_to_keys}/../KEYS/${local.bastion_key}.pem"
}

#####################################################################################################
/* Jenkins server */
module "jenkins_server" {
  source                      = "../../modules/jenkins_srv_clone"
  region                      = var.region
  jenkins_purpose             = "JenkinsSrv"
  type_of_subnet              = "Private"
  subnet_association_tag      = "Master"
  jenkins_sec_group_array     = concat(module.reguest_data.sec_grp_ssh_ids, module.reguest_data.sec_grp_jenkins_ids, module.reguest_data.sec_grp_consul_ids)
  access_key_name             = module.reguest_data.key_pair_master
  access_key_file             = file(local.path_to_master_key)
  bastion_public_ip           = data.aws_instance.bastion.public_ip
  bastion_access_key          = file(local.path_to_bastion_key)
  vpc_id                      = module.reguest_data.vpc_id
  jenkins_OS                  = "Ubuntu"
  iam_instance_profile        = module.iam_roles_describe_jenkins_server.iam_instance_profile
  associate_public_ip_address = false
  application_name            = var.application_name
  application_task            = var.application_task
  created_by                  = var.created_by
  consul_prefix               = "ConsulAgent"
  consul_app_discovery_tag    = "Consul"
}


/* Jenkins server LB */
module "jenkins_server_load_balancers" {
  source                   = "../../modules/load_balancer"
  subnets                  = module.reguest_data.pub_subnets_ids
  lb_sec_group_array       = concat(module.reguest_data.sec_grp_http_ids, module.reguest_data.sec_grp_jenkins_ids, module.reguest_data.sec_grp_ssh_ids, )
  application_task         = var.application_task
  application_name         = var.application_name
  created_by               = var.created_by
  vpc_id                   = module.reguest_data.vpc_id
  servers_for_attach_to_lb = concat(module.jenkins_server.jenkins_servers_id_arr)
  listener_ports           = [80, 8080]
  listener_protocols       = ["HTTP", "HTTP"]
  idle_timeout             = 60
  internal                 = false
  lb_purpose               = "jenkins"
  target_port              = 8080
}

######################################################################################
/* Jenkins agent */
module "jenkins_agent" {
  source                      = "../../modules/jenkins_agent"
  region                      = var.region
  jenkins_purpose             = "JenkinsSlave"
  type_of_subnet              = "Private"
  subnet_association_tag      = "Master"
  count_instances             = 2
  jenkins_sec_group_array     = concat(module.reguest_data.sec_grp_ssh_ids, module.reguest_data.sec_grp_consul_ids)
  access_key_name             = module.reguest_data.key_pair_master
  access_key_file             = file(local.path_to_master_key)
  bastion_public_ip           = data.aws_instance.bastion.public_ip
  bastion_access_key          = file(local.path_to_bastion_key)
  vpc_id                      = module.reguest_data.vpc_id
  jenkins_OS                  = "Ubuntu"
  iam_instance_profile        = module.iam_roles_describe_jenkins_agent.iam_instance_profile
  associate_public_ip_address = false
  application_name            = var.application_name
  application_task            = var.application_task
  created_by                  = var.created_by
  consul_prefix               = "ConsulAgent"
  consul_app_discovery_tag    = "Consul"
  aws_default_acss_key        = var.aws_default_acss_key
  aws_default_secret_key      = var.aws_default_secret_key
  aws_default_region          = var.aws_default_region
}
