/*
  Galit Udovik

  OpsSchool DevOps cource
  Received data from AWS
*/

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "target" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = data.aws_eks_cluster.target.name
}
