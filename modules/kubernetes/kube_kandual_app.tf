# # Kubernetes provider
# # https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes

locals {
  k8s_namespace            = "kandula"
  k8s_service_account_name = "${local.k8s_namespace}-service-account"
}


resource "null_resource" "update_cluster_name_locally" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = "aws eks --region=${data.aws_region.current.name} update-kubeconfig --name ${data.aws_eks_cluster.cluster.name}"
  }
}

provider "kubernetes" {
  /*config_path            = "~/.kube/config"
  config_context         = "arn:aws:eks:eu-central-1:${data.aws_caller_identity.current.account_id}:cluster/${module.eks.cluster_id}"*/
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Create namespace for kandula
resource "kubernetes_namespace_v1" "kandula_app_namespace" {
  metadata {
    name = local.k8s_namespace
  }
  depends_on = [module.eks]
}
resource "kubernetes_service_account" "kube_service_account" {
  metadata {
    name      = local.k8s_service_account_name
    namespace = local.k8s_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_kube_assumable_role_admin.iam_role_arn
    }
  }
  depends_on = [module.eks, module.iam_kube_assumable_role_admin]
}

module "iam_kube_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.1.0"
  create_role                   = true
  role_name                     = "${local.k8s_namespace}-kube-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  provider_urls                 = [replace(module.eks.cluster_oidc_issuer_url, "https://", "")]
  role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_namespace}:${local.k8s_service_account_name}"]
  depends_on                    = [module.eks]


  tags = {
    Role      = "Role-assume-${local.k8s_namespace}-kube-role"
    Name      = "${var.application_task} ${var.application_name} kube"
    Purpose   = "Kubernetes"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}
