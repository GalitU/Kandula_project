output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "cluster_status" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_status
}

output eks_managed_node_groups {
  value = module.eks.eks_managed_node_groups
}
output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "eks_cluster_auth" {
  value = data.aws_eks_cluster_auth.cluster
}

output eks_auth_configmap_yaml {
  value = module.eks_auth.aws_auth_configmap_yaml
}

output eks_map_accounts {
  value = module.eks_auth.map_accounts
}

output eks_map_roles {
  value = module.eks_auth.map_roles
}

output eks_map_users {
  value = module.eks_auth.map_users
}
