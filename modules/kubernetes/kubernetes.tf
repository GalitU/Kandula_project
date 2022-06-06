# # Kubernetes provider
# # https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

resource "kubernetes_service_account" "opsschool_sa" {
  metadata {
    name      = local.k8s_service_account_name
    namespace = local.k8s_service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_kube_assumable_role_admin.iam_role_arn
    }
  }
  depends_on = [module.eks]
}

resource "aws_ec2_tag" "ingress_tag_pub_subnet_kube" {
  count       = length(var.kube_pub_subnets_ids)
  resource_id = var.kube_pub_subnets_ids[count.index]
  key         = "kubernetes.io/cluster/${local.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "ingress_tag_pub_subnet_elb" {
  count       = length(var.kube_pub_subnets_ids)
  resource_id = var.kube_pub_subnets_ids[count.index]
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "ingress_tag_pvt_subnet_kube" {
  count       = length(var.kube_pvt_subnets_ids)
  resource_id = var.kube_pvt_subnets_ids[count.index]
  key         = "kubernetes.io/cluster/${local.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "ingress_tag_pvt_subnet_elb" {
  count       = length(var.kube_pvt_subnets_ids)
  resource_id = var.kube_pvt_subnets_ids[count.index]
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}
