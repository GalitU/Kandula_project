resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  #cluster_name = "${var.cluster_name}-${random_string.suffix.result}"
  cluster_name = var.cluster_name
}

data "aws_subnets" "associate_pub_subnets_by_name_filter" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }

  filter {
    name   = "tag:Purpose"
    values = ["Kube"]
  }
}

data "aws_subnets" "associate_pvt_subnets_by_name_filter" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
  filter {
    name   = "tag:Purpose"
    values = ["Kube"]
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.6.1"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids      = var.kube_pvt_subnets_ids

  enable_irsa = true
  vpc_id      = var.vpc_id
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = var.kube_node_sec_groups
  }

  eks_managed_node_groups = {

    Kandula_worker_m = {
      min_size       = 2
      max_size       = 6
      desired_size   = 2
      instance_types = ["t3.medium"]
    }

    Kandula_worker_l = {
      min_size       = 2
      max_size       = 6
      desired_size   = 2
      instance_types = ["t3.large"]
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
    #ConsulAppDiscoveryTag  = "Consul"
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}
