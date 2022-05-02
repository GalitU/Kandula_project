/*
  Galit Udovik
  OpsSchool DevOps cource
  Main file
*/

locals {
  # Subnet purpose
  subnet_pvt_prefix_arr = ["Consul", "Consul", "Master"]
  subnet_pub_prefix_arr = ["Bastion", "General"]

  # CIDR per purpose
  subnet_pvt_cidr_arr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_pub_cidr_arr = ["10.0.31.0/24", "10.0.32.0/24"]
}

module "vpc" {
  source                         = "../../modules/vpc"
  region                         = var.region
  cidr_block_pvt                 = local.subnet_pvt_cidr_arr
  cidr_block_pub                 = local.subnet_pub_cidr_arr
  subnet_pvt_prefix_template_arr = local.subnet_pvt_prefix_arr
  subnet_pub_prefix_template_arr = local.subnet_pub_prefix_arr
  application_name               = var.application_name
  application_task               = var.application_task
  created_by                     = var.created_by
}

module "key_credentials_consul" {
  source           = "../../modules/key_credentials"
  application_name = var.application_name
  application_task = var.application_task
  created_by       = var.created_by
  root_directory   = abspath(path.module)
  key_purpose      = "Consul"
}

module "key_credentials_bastion" {
  source           = "../../modules/key_credentials"
  application_task = var.application_task
  application_name = var.application_name
  created_by       = var.created_by
  root_directory   = abspath(path.module)
  key_purpose      = "Bastion"
}

module "key_credentials_ansible" {
  source           = "../../modules/key_credentials"
  application_task = var.application_task
  application_name = var.application_name
  created_by       = var.created_by
  root_directory   = abspath(path.module)
  key_purpose      = "Ansible"
}

module "iam_roles_describe" {
  source                    = "../../modules/roles"
  access_policy_description = "Describe"
  role_policy_type          = "sts:AssumeRole"
  access_policy_type        = "ec2:DescribeInstances"
  application_name          = var.application_name
  application_task          = var.application_task
  created_by                = var.created_by
}

/*
module "s3" {
  source              = "../../modules/s3"
  ec2_role            = module.iam_roles_describe.role
  ec2_role_assign_for = "ec2_web_webservers"
  application_name    = var.application_name
  application_task     = var.application_task
  created_by          = var.created_by
}
*/

module "ec2_bastion_server" {
  source                      = "../../modules/ec2_servers"
  region                      = var.region
  ec2_instance_type           = var.ec2_instance_type
  ami                         = var.ami
  count_instances             = 1
  ec2_purpose                 = "Bastion"
  type_of_subnet              = "Public"
  subnet_association_tag      = "Bastion"
  ec2_sec_group_array         = [module.vpc.sec_grp_ssh.id]
  access_key_name             = module.key_credentials_bastion.private_key_name
  vpc_id                      = module.vpc.vpc_id
  ec2_OS                      = "Ubuntu"
  iam_instance_profile        = module.iam_roles_describe.iam_instance_profile
  user_data_file              = file("${path.module}/../../modules/scripts/bastion.sh")
  associate_public_ip_address = true
  application_name            = var.application_name
  application_task            = var.application_task
  created_by                  = var.created_by
  consul_prefix               = ""
  consul_app_discovery_tag    = ""
}

module "ec2_ansible_server" {
  source                      = "../../modules/ec2_servers"
  region                      = var.region
  ec2_instance_type           = var.ec2_instance_type
  ami                         = var.ami
  count_instances             = 1
  ec2_purpose                 = "Ansible"
  type_of_subnet              = "Private"
  subnet_association_tag      = "Master"
  ec2_sec_group_array         = [module.vpc.sec_grp_ssh.id]
  access_key_name             = module.key_credentials_ansible.private_key_name
  vpc_id                      = module.vpc.vpc_id
  ec2_OS                      = "Ubuntu"
  iam_instance_profile        = module.iam_roles_describe.iam_instance_profile
  user_data_file              = file("${path.module}/../../modules/scripts/ansible.sh")
  associate_public_ip_address = false
  application_name            = var.application_name
  application_task            = var.application_task
  created_by                  = var.created_by
  consul_prefix               = "ConsulAgent"
  consul_app_discovery_tag    = "Consul"
}


module "ec2_consul_servers" {
  source                      = "../../modules/ec2_servers"
  region                      = var.region
  ec2_instance_type           = var.ec2_instance_type
  ami                         = var.ami
  count_instances             = 3
  ec2_purpose                 = "ConsulSrv"
  type_of_subnet              = "Private"
  subnet_association_tag      = "Consul"
  ec2_sec_group_array         = [module.vpc.sec_grp_ssh.id, module.vpc.sec_grp_consul.id]
  access_key_name             = module.key_credentials_consul.private_key_name
  vpc_id                      = module.vpc.vpc_id
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

module "ec2_web_servers" {
  source                      = "../../modules/ec2_servers"
  region                      = var.region
  ec2_instance_type           = var.ec2_instance_type
  ami                         = var.ami
  count_instances             = 1
  ec2_purpose                 = "WebServer"
  type_of_subnet              = "Private"
  subnet_association_tag      = "Consul"
  ec2_sec_group_array         = [module.vpc.sec_grp_http.id, module.vpc.sec_grp_ssh.id, module.vpc.sec_grp_consul.id]
  access_key_name             = module.key_credentials_consul.private_key_name
  vpc_id                      = module.vpc.vpc_id
  ec2_OS                      = "Ubuntu"
  iam_instance_profile        = module.iam_roles_describe.iam_instance_profile
  user_data_file              = file("${path.module}/../../modules/scripts/webserver_data.sh") # data.template_file.consul_agent_setup_script.template
  associate_public_ip_address = false
  application_name            = var.application_name
  application_task            = var.application_task
  created_by                  = var.created_by
  consul_prefix               = "ConsulAgent"
  consul_app_discovery_tag    = "Consul"
}


module "consul_server_load_balancers" {
  source                   = "../../modules/load_balancer"
  subnets                  = [for subnet in module.vpc.pub_subnets : subnet.id]
  lb_sec_group_array       = [module.vpc.sec_grp_http.id, module.vpc.sec_grp_https.id, module.vpc.sec_grp_consul.id]
  application_task         = var.application_task
  application_name         = var.application_name
  created_by               = var.created_by
  vpc_id                   = module.vpc.vpc_id
  servers_for_attach_to_lb = concat(module.ec2_consul_servers.ec2_servers_id_arr)
  listener_ports           = [80, 8500]
  listener_protocols       = ["HTTP", "HTTP"]
  idle_timeout             = 60
  internal                 = false
  lb_purpose               = "consul"
  target_port              = 8500
}

module "consul_agent_load_balancers" {
  source                   = "../../modules/load_balancer"
  subnets                  = [for subnet in module.vpc.pub_subnets : subnet.id]
  lb_sec_group_array       = [module.vpc.sec_grp_http.id, module.vpc.sec_grp_https.id, module.vpc.sec_grp_consul.id]
  application_task         = var.application_task
  application_name         = var.application_name
  created_by               = var.created_by
  vpc_id                   = module.vpc.vpc_id
  servers_for_attach_to_lb = module.ec2_web_servers.ec2_servers_id_arr
  listener_ports           = [80]
  listener_protocols       = ["HTTP"]
  idle_timeout             = 60
  internal                 = false
  lb_purpose               = "web-servers"
  target_port              = 80
}
