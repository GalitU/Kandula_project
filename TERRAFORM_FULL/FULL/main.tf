/*
  Galit Udovik
  OpsSchool DevOps cource
  Main file
*/

####-----  VPC  -------------------------------------------------------------------------

locals {
  # Subnet purpose
  subnet_pvt_prefix_arr = ["Consul", "Consul", "Master", "Master", "WebServers", "WebServers"]
  subnet_pub_prefix_arr = ["Bastion", "General"]

  # CIDR per purpose
  subnet_pvt_cidr_arr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  subnet_pub_cidr_arr = ["10.0.31.0/24", "10.0.32.0/24"]
}

module "gu_vpc" {
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

####-----  Keys  -------------------------------------------------------------------------

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

####---- GET VPC Data --------------------------------------------------------------------------

module "gu_reguest_data" {
  source                 = "../../modules/data"
  region                 = var.region
  application_name       = var.application_name
  application_task       = var.application_task
  created_by             = var.created_by
  vpc_name               = join("-", ["VPC", lower(var.application_name), var.application_task])
  route53_host_zone_name = "galitu.site"
}

####---- Bastion host  --------------------------------------------------------------------------

module "gu_bastion_server" {
  source = "../../modules/bastion"
  region = var.region
  ec2_sec_group_array = concat(module.gu_reguest_data.sec_grp_bastion_ids,
    module.gu_reguest_data.sec_grp_consul_ids,
  module.gu_reguest_data.sec_grp_node_exporter)
  application_name = var.application_name
  application_task = var.application_task
  created_by       = var.created_by
  depends_on       = [module.gu_reguest_data]
}

####------  KUBE  -----------------------------------------------------------------------

locals {
  cluster_name = "kandula-prj-kube"
}

module "gu_kube" {
  source           = "../../modules/kubernetes"
  vpc_id           = module.gu_reguest_data.vpc_id
  application_task = var.application_task
  application_name = var.application_name
  created_by       = var.created_by
  cluster_name     = local.cluster_name
  kube_node_sec_groups = concat(
    module.gu_reguest_data.kube_security_group_ids,
    module.gu_reguest_data.sec_grp_consul_ids,
    module.gu_reguest_data.sec_grp_node_exporter
    /*                                ,
                                module.gu_reguest_data.sec_grp_monitoring,
                                module.gu_reguest_data.sec_grp_grafana_prometheus_ui
*/
  )
  kube_pub_subnets_ids       = module.gu_reguest_data.pub_subnets_ids
  kube_pvt_subnets_ids       = module.gu_reguest_data.workers_pvt_subnets_ids
  kube_additional_role_names = ["JenkinsSrv_Describe", "JenkinsAgent_Describe"]
}

data "aws_eks_cluster" "target" {
  name = local.cluster_name
  depends_on = [
    module.gu_kube
  ]
}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = data.aws_eks_cluster.target.name
  depends_on = [
    module.gu_kube
  ]
}

provider "kubernetes" {
  config_path            = "~/.kube/config"
  config_context         = "arn:aws:eks:eu-central-1:${data.aws_caller_identity.current.account_id}:cluster/${local.cluster_name}"
  host                   = data.aws_eks_cluster.target.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
}

module "alb_ingress_controller" {
  source  = "iplabs/alb-ingress-controller/kubernetes"
  version = "3.4.0"

  providers = {
    kubernetes = kubernetes
  }

  k8s_cluster_type         = "eks"
  k8s_namespace            = "kube-system"
  aws_vpc_id               = module.gu_reguest_data.vpc_id
  aws_iam_path_prefix      = ""
  aws_resource_name_prefix = "gu-"
  aws_region_name          = data.aws_region.current.name
  k8s_cluster_name         = data.aws_eks_cluster.target.name
  aws_tags = {
    Name      = "IngressCtrl-${var.application_task} ${var.application_name}"
    Purpose   = "Kubernetes"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
    #ConsulPrefixForAnsible = "ConsulAgent-${var.application_name}-${var.application_task}"
    #ConsulAppDiscoveryTag  = "Consul"
  }

  depends_on = [
    module.gu_kube
  ]
}


####------  KUBE applications -----------------------------------------------------------------------

module "gu_kube_kandula_application" {
  source                 = "../../modules/kube_kandula_application"
  cluster_name           = local.cluster_name
  kandula_image_version  = "v4.0.11.cd1af5e2"
  aws_access_key_id      = var.aws_access_key_id
  aws_sercret_access_key = var.aws_sercret_access_key
  aws_default_region     = var.aws_default_region
  login_user_name        = var.login_user_name
  login_password         = var.login_password
  termination_dry_run    = var.termination_dry_run
  route53_host_zone_name = "galitu.site"
}

####------  Jenkins  -----------------------------------------------------------------------

locals {
  root_path                         = abspath(path.module)
  assume_policy_file_path           = "${local.root_path}/../../modules/roles/policies/assume_role.json"
  jenkins_server_access_policy_file = "${local.root_path}/../../modules/roles/policies/jenkins_server_policy.json"
  jenkins_agent_access_policy_file  = "${local.root_path}/../../modules/roles/policies/jenkins_agents_policy.json"
}

module "gu_iam_roles_describe_jenkins_server" {
  source                    = "../../modules/roles"
  access_policy_description = "Describe"
  role_policy_type          = file(local.assume_policy_file_path)
  access_policy_type        = file(local.jenkins_server_access_policy_file)
  purpose                   = "JenkinsSrv"
  application_name          = var.application_name
  application_task          = var.application_task
  created_by                = var.created_by
}

module "gu_iam_roles_describe_jenkins_agent" {
  source                    = "../../modules/roles"
  access_policy_description = "Describe"
  role_policy_type          = file(local.assume_policy_file_path)
  access_policy_type        = file(local.jenkins_agent_access_policy_file)
  purpose                   = "JenkinsAgent"
  application_name          = var.application_name
  application_task          = var.application_task
  created_by                = var.created_by
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

locals {
  abs_path_to_keys                          = abspath(path.module)
  master_key                                = module.gu_reguest_data.key_pair_master
  bastion_key                               = module.gu_reguest_data.key_pair_bastion
  path_to_keys                              = "${local.abs_path_to_keys}/../KEYS/"
  path_to_master_key                        = "${local.abs_path_to_keys}/../KEYS/${local.master_key}.pem"
  path_to_bastion_key                       = "${local.abs_path_to_keys}/../KEYS/${local.bastion_key}.pem"
  path_to_consul_key                        = "${local.abs_path_to_keys}/../KEYS/${local.consul_key}.pem"
  consul_assume_policy_file_path            = "${local.root_path}/../../modules/roles/policies/assume_role.json"
  consul_describe_server_access_policy_file = "${local.root_path}/../../modules/roles/policies/describe_instances.json"
}

#####################################################################################################
/* Jenkins server */
module "gu_jenkins_server" {
  source                 = "../../modules/jenkins_srv_clone"
  region                 = var.region
  jenkins_purpose        = "JenkinsSrv"
  type_of_subnet         = "Private"
  subnet_association_tag = "Master"
  jenkins_sec_group_array = concat(
    module.gu_reguest_data.sec_grp_ssh_ids,
    module.gu_reguest_data.sec_grp_jenkins_ids,
    module.gu_reguest_data.sec_grp_consul_ids,
  module.gu_reguest_data.sec_grp_node_exporter)
  access_key_name             = module.gu_reguest_data.key_pair_master
  access_key_file             = file(local.path_to_master_key)
  bastion_public_ip           = data.aws_instance.bastion.public_ip
  bastion_access_key          = file(local.path_to_bastion_key)
  vpc_id                      = module.gu_reguest_data.vpc_id
  jenkins_OS                  = "Ubuntu"
  iam_instance_profile        = module.gu_iam_roles_describe_jenkins_server.iam_instance_profile
  associate_public_ip_address = false
  application_name            = var.application_name
  application_task            = var.application_task
  created_by                  = var.created_by
  consul_prefix               = "ConsulAgent"
  consul_app_discovery_tag    = "Consul"
}


/* Jenkins server LB */
module "gu_jenkins_server_load_balancers" {
  source                   = "../../modules/load_balancer"
  subnets                  = module.gu_reguest_data.pub_subnets_ids
  lb_sec_group_array       = concat(module.gu_reguest_data.sec_grp_http_ids, module.gu_reguest_data.sec_grp_https_ids)
  application_task         = var.application_task
  application_name         = var.application_name
  created_by               = var.created_by
  vpc_id                   = module.gu_reguest_data.vpc_id
  servers_for_attach_to_lb = concat(module.gu_jenkins_server.jenkins_servers_id_arr)
  listener_ports           = [443]
  listener_protocols       = ["HTTPS"]
  aws_acm_certificate_id   = module.gu_reguest_data.aws_acm_certificate_arn
  idle_timeout             = 60
  internal                 = false
  lb_purpose               = "jenkins"
  target_port              = 8080
}

######################################################################################
/* Jenkins agent */
module "gu_jenkins_agent" {
  depends_on = [module.gu_jenkins_server_load_balancers]

  source                 = "../../modules/jenkins_agent"
  region                 = var.region
  jenkins_purpose        = "JenkinsSlave"
  type_of_subnet         = "Private"
  subnet_association_tag = "Master"
  count_instances        = var.jenkins_agents_count_instances
  jenkins_sec_group_array = concat(module.gu_reguest_data.sec_grp_ssh_ids,
    module.gu_reguest_data.sec_grp_consul_ids,
  module.gu_reguest_data.sec_grp_node_exporter)
  access_key_name             = module.gu_reguest_data.key_pair_master
  access_key_file             = file(local.path_to_master_key)
  bastion_public_ip           = data.aws_instance.bastion.public_ip
  bastion_access_key          = file(local.path_to_bastion_key)
  vpc_id                      = module.gu_reguest_data.vpc_id
  jenkins_OS                  = "Ubuntu"
  iam_instance_profile        = module.gu_iam_roles_describe_jenkins_agent.iam_instance_profile
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

module "gu_route53_jenkins" {
  source                     = "../../modules/route_53"
  route53_host_zone_name     = "galitu.site"
  route53_record_name        = "jenkins"
  route53_address_list_array = [module.gu_jenkins_server_load_balancers.alb_dns]
  ttl                        = 300
  application_task           = var.application_task
  application_name           = var.application_name
  created_by                 = var.created_by
  application_owner          = var.application_owner
  depends_on                 = [module.gu_jenkins_server_load_balancers]
}

####------  Consul  -----------------------------------------------------------------------

module "gu_iam_roles_describe_consul" {
  source                    = "../../modules/roles"
  access_policy_description = "Describe"
  role_policy_type          = file(local.consul_assume_policy_file_path)
  access_policy_type        = file(local.consul_describe_server_access_policy_file)
  purpose                   = "Consul"
  application_name          = var.application_name
  application_task          = var.application_task
  created_by                = var.created_by
}

#####################################################################################################
/* Consul servers * 3 */
module "gu_ec2_consul_servers" {
  source                 = "../../modules/ec2_servers"
  region                 = var.region
  ec2_instance_type      = var.ec2_instance_type
  ami                    = var.ami
  count_instances        = var.consul_count_instances
  ec2_purpose            = "ConsulSrv"
  type_of_subnet         = "Private"
  subnet_association_tag = "Consul"
  ec2_sec_group_array = concat(
    module.gu_reguest_data.sec_grp_ssh_ids,
    module.gu_reguest_data.sec_grp_consul_ui_ids,
    module.gu_reguest_data.sec_grp_consul_ids,
  module.gu_reguest_data.sec_grp_node_exporter)
  access_key_name             = local.consul_key
  vpc_id                      = module.gu_reguest_data.vpc_id
  ec2_OS                      = "Ubuntu"
  iam_instance_profile        = module.gu_iam_roles_describe_consul.iam_instance_profile
  user_data_file              = file("${path.module}/../../modules/scripts/empty.sh") #data.template_file.consul_server_setup_script.template
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

module "gu_route53_consul" {
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

####------  Monitoring  -----------------------------------------------------------------------
