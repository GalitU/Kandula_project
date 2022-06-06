###
### https://registry.terraform.io/modules/aidanmelen/eks-auth/aws/latest
###

data "aws_caller_identity" "current" {}

locals {
  map_roles = [for role in var.kube_additional_role_names : {
    rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Role_${role}_${var.application_task}_${var.application_name}_join"
    username = "Role_${role}_${var.application_task}_${var.application_name}_join"
    groups   = ["system:masters"]

  }]
}

module "eks_auth" {
  source                   = "aidanmelen/eks-auth/aws"
  version                  = "1.0.0"
  eks                      = module.eks
  wait_for_cluster_timeout = 300
  map_roles                = local.map_roles

  depends_on = [module.eks]
}
