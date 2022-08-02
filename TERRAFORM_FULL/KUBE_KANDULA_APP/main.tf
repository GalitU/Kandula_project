/*
  Galit Udovik
  OpsSchool DevOps cource
  Main file
*/

locals {
  cluster_name = "kandula-prj-kube"
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

provider "kubernetes" {
  config_path            = "~/.kube/config"
  config_context         = "arn:aws:eks:eu-central-1:${data.aws_caller_identity.current.account_id}:cluster/${local.cluster_name}"
  host                   = data.aws_eks_cluster.target.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
}

#########################################################################################
/* EKS Kandula application resources */

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
