/*
  Galit Udovik

  OpsSchool DevOps cource
  Output data
*/

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}
output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}
output "data_aws_region" {
  value = data.aws_region.current.name
}
output "data_aws_region_description" {
  value = data.aws_region.current.description
}

/* VPC info */
output "vpc_id" {
  value = module.reguest_data.vpc_id
}

/*
// S3
output "s3_name" {
  value = module.s3.s3_bucket_name
}
output "s3_name_arn" {
  value = module.s3.s3_name_arn
}
*/

/* Kubernetes */
output "kube_cluster_id" {
  description = "EKS cluster ID."
  value       = module.kubernetes.cluster_id
}
output "kube_cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.kubernetes.cluster_endpoint
}
output "kube_cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.kubernetes.cluster_security_group_id
}
output "kube_cluster_name" {
  value = module.kubernetes.cluster_name
}
output "kube_oidc_provider_arn" {
  value = module.kubernetes.oidc_provider_arn
}
