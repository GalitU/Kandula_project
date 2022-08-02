data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
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
