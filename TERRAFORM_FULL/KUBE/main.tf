/*
  Galit Udovik
  OpsSchool DevOps cource
  Main file
*/

module "reguest_data" {
  source                 = "../../modules/data"
  region                 = var.region
  application_name       = var.application_name
  application_task       = var.application_task
  created_by             = var.created_by
  vpc_name               = join("-", ["VPC", lower(var.application_name), var.application_task])
  route53_host_zone_name = "galitu.site"
}

locals {
  cluster_name = "kandula-mid-kube"
}
#########################################################################################
/* EKS environment */
module "kubernetes" {
  source                     = "../../modules/kubernetes"
  vpc_id                     = module.reguest_data.vpc_id
  application_task           = var.application_task
  application_name           = var.application_name
  created_by                 = var.created_by
  cluster_name               = local.cluster_name
  kube_node_sec_groups       = concat(module.reguest_data.kube_security_group_ids, module.reguest_data.sec_grp_consul_ids)
  kube_pub_subnets_ids       = module.reguest_data.pub_subnets_ids
  kube_pvt_subnets_ids       = module.reguest_data.workers_pvt_subnets_ids
  kube_additional_role_names = ["JenkinsSrv_Describe", "JenkinsAgent_Describe"]
}


###########   ###########   ###########   ###########   ###########   ###########   ###########
data "aws_eks_cluster" "target" {
  name = local.cluster_name
  depends_on = [module.kubernetes]
}
data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = data.aws_eks_cluster.target.name
}

provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.target.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
  #load_config_file       = false
}

module "alb_ingress_controller" {
  source  = "iplabs/alb-ingress-controller/kubernetes"
  version = "3.4.0"

  providers = {
    kubernetes = kubernetes.eks
  }

  aws_vpc_id = module.reguest_data.vpc_id

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = data.aws_region.current.name
  k8s_cluster_name = data.aws_eks_cluster.target.name

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
  depends_on = [module.kubernetes]
}
