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
  purpose                   = "Consul"
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

#####################################################################################################
/* Consul servers * 3 */
module "ec2_consul_servers" {
  source                      = "../../modules/ec2_servers"
  region                      = var.region
  ec2_instance_type           = var.ec2_instance_type
  ami                         = var.ami
  count_instances             = 3
  ec2_purpose                 = "ConsulSrv"
  type_of_subnet              = "Private"
  subnet_association_tag      = "Consul"
  ec2_sec_group_array         = concat(module.reguest_data.sec_grp_ssh_ids, module.reguest_data.sec_grp_consul_ui_ids, module.reguest_data.sec_grp_consul_ids)
  access_key_name             = module.reguest_data.key_pair_consul
  vpc_id                      = module.reguest_data.vpc_id
  ec2_OS                      = "Ubuntu"
  iam_instance_profile        = module.iam_roles_describe.iam_instance_profile
  user_data_file              = file("${path.module}/../../modules/scripts/empty.sh") #data.template_file.consul_server_setup_script.template
  associate_public_ip_address = false
  application_name            = var.application_name
  application_task            = var.application_task
  created_by                  = var.created_by
  consul_prefix               = "ConsulServer"
  consul_app_discovery_tag    = "Consul"
}


module "consul_server_load_balancers" {
  source                   = "../../modules/load_balancer"
  subnets                  = module.reguest_data.pub_subnets_ids
  lb_sec_group_array       = concat(module.reguest_data.sec_grp_http_ids, module.reguest_data.sec_grp_ssh_ids, module.reguest_data.sec_grp_consul_ui_ids, module.reguest_data.sec_grp_consul_ids)
  application_task         = var.application_task
  application_name         = var.application_name
  created_by               = var.created_by
  vpc_id                   = module.reguest_data.vpc_id
  servers_for_attach_to_lb = concat(module.ec2_consul_servers.ec2_servers_id_arr)
  listener_ports           = [80, 8500]
  listener_protocols       = ["HTTP", "HTTP"]
  idle_timeout             = 60
  internal                 = false
  lb_purpose               = "consul"
  target_port              = 8500
}
