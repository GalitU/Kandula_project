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

module "gu_iam_roles_describe" {
  source                    = "../../modules/roles"
  access_policy_description = "Describe"
  role_policy_type          = file(local.assume_policy_file_path)
  access_policy_type        = file(local.describe_server_access_policy_file)
  purpose                   = "Consul"
  application_name          = var.application_name
  application_task          = var.application_task
  created_by                = var.created_by
}

module "gu_reguest_data" {
  source                 = "../../modules/data"
  region                 = var.region
  application_name       = var.application_name
  application_task       = var.application_task
  created_by             = var.created_by
  vpc_name               = join("-", ["VPC", lower(var.application_name), var.application_task])
  route53_host_zone_name = "galitu.site"
}

locals {
  abs_path_to_keys    = abspath(path.module)
  master_key          = module.gu_reguest_data.key_pair_master
  bastion_key         = module.gu_reguest_data.key_pair_bastion
  consul_key         = module.gu_reguest_data.key_pair_consul
  path_to_keys        = "${local.abs_path_to_keys}/../KEYS/"
  path_to_master_key  = "${local.abs_path_to_keys}/../KEYS/${local.master_key}.pem"
  path_to_bastion_key = "${local.abs_path_to_keys}/../KEYS/${local.bastion_key}.pem"
  path_to_consul_key = "${local.abs_path_to_keys}/../KEYS/${local.consul_key}.pem"
}


data "aws_instance" "bastion" {
  instance_tags = {
    Purpose  = "Bastion"
    Task     = var.application_task
    App_name = var.application_name
  }
  filter {
    name   = "vpc-id"
    values = [module.gu_reguest_data.vpc_id]
  }
}

#####################################################################################################
/* Consul servers * 3 */
module "gu_ec2_consul_servers" {
  source                      = "../../modules/ec2_servers"
  region                      = var.region
  ec2_instance_type           = var.ec2_instance_type
  ami                         = var.ami
  count_instances             = var.count_instances
  ec2_purpose                 = "ConsulSrv"
  type_of_subnet              = "Private"
  subnet_association_tag      = "Consul"
  ec2_sec_group_array         = concat(module.gu_reguest_data.sec_grp_ssh_ids,
                                module.gu_reguest_data.sec_grp_consul_ui_ids,
                                module.gu_reguest_data.sec_grp_consul_ids,
                                module.gu_reguest_data.sec_grp_node_exporter)
  access_key_name             = local.consul_key
  vpc_id                      = module.gu_reguest_data.vpc_id
  ec2_OS                      = "Ubuntu"
  iam_instance_profile        = module.gu_iam_roles_describe.iam_instance_profile
  user_data_file              = file("${path.module}/../../modules/scripts/consul.sh") #data.template_file.consul_server_setup_script.template
  associate_public_ip_address = false
  application_name            = var.application_name
  application_task            = var.application_task
  created_by                  = var.created_by
  consul_prefix               = "ConsulServer"
  consul_app_discovery_tag    = "Consul"
}


module "gu_consul_server_load_balancers" {
  source                   = "../../modules/load_balancer"
  subnets                  = module.gu_reguest_data.pub_subnets_ids
  lb_sec_group_array       = concat(module.gu_reguest_data.sec_grp_http_ids, module.gu_reguest_data.sec_grp_https_ids)
  application_task         = var.application_task
  application_name         = var.application_name
  created_by               = var.created_by
  vpc_id                   = module.gu_reguest_data.vpc_id
  servers_for_attach_to_lb = concat(module.gu_ec2_consul_servers.ec2_servers_id_arr)
  listener_ports           = [443]
  listener_protocols       = ["HTTPS"]
  aws_acm_certificate_id   = module.gu_reguest_data.aws_acm_certificate_arn
  idle_timeout             = 60
  internal                 = false
  lb_purpose               = "consul"
  target_port              = 8500
}


module "gu_route53" {
  source                     = "../../modules/route_53"
  route53_host_zone_name     = "galitu.site"
  route53_record_name        = "consul"
  route53_address_list_array = [module.gu_consul_server_load_balancers.alb_dns]
  ttl                        = 300
  application_task           = var.application_task
  application_name           = var.application_name
  created_by                 = var.created_by
  application_owner          = var.application_owner
  depends_on                 = [module.gu_consul_server_load_balancers]
}
