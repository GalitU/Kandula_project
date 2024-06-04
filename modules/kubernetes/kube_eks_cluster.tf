resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  #cluster_name = "${var.cluster_name}-${random_string.suffix.result}"
  cluster_name = var.cluster_name
}

module "eks" {
  source                                 = "terraform-aws-modules/eks/aws"
  version                                = "18.23.0"
  cluster_name                           = local.cluster_name
  cluster_version                        = var.kubernetes_version
  create_cloudwatch_log_group            = false
  cloudwatch_log_group_retention_in_days = 1
  enable_irsa                            = true
  vpc_id                                 = var.vpc_id
  subnet_ids                             = var.kube_pvt_subnets_ids
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = var.kube_node_sec_groups
  }

  eks_managed_node_groups = {

    Kandula_worker_m_1 = {
      min_size       = 2
      max_size       = 6
      desired_size   = 2
      instance_types = ["t3.medium"]
      tags = {
          Kube_purpose = "Medium"
      }
    }

    Kandula_worker_m_2 = {
      min_size       = 2
      max_size       = 6
      desired_size   = 2
      instance_types = ["t3.medium"]
      tags = {
          Kube_purpose = "Medium"
      }
    }
  }
  tags = {
    Name      = "${var.application_task} ${var.application_name} kube"
    Purpose   = "Kubernetes"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
    #ConsulPrefixForAnsible = "ConsulAgent-${var.application_name}-${var.application_task}"
    ConsulAppDiscoveryTag  = "Consul"
  }
}
