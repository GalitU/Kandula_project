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
output "kube_cluster_name" {
  value = local.cluster_name
}

/* VPC info */
output "vpc_id" {
  value = module.gu_reguest_data.vpc_id
}

/* Kubernetes */
output "kandula_app_namespace_name" {
  value = module.gu_kube_kandula_application.kandula_app_namespace_name
}
output "kubernetes_deployment_name" {
  value = module.gu_kube_kandula_application.kubernetes_deployment_name
}
output "kubernetes_service_name" {
  value = module.gu_kube_kandula_application.kubernetes_service_name
}
output "kubernetes_ingress_name" {
  value = module.gu_kube_kandula_application.kubernetes_ingress_name
}
output "kubernetes_ingress_lb" {
  value = module.gu_kube_kandula_application.kubernetes_ingress_lb
}
output "aws_acm_certificate" {
  value = module.gu_kube_kandula_application.aws_acm_certificate
}
output "web_kandula_address" {
  value = module.gu_kube_kandula_application.web_kandula_address
}
output "kubernetes_ingress_grafana_name" {
  value = module.gu_kube_kandula_application.kubernetes_ingress_grafana_name
}
output "kubernetes_ingress_grafana_lb" {
  value = module.gu_kube_kandula_application.kubernetes_ingress_grafana_lb
}
output "web_grafana_address" {
  value = module.gu_kube_kandula_application.web_grafana_address
}
output "kubernetes_ingress_prometheus_name" {
  value = module.gu_kube_kandula_application.kubernetes_ingress_prometheus_name
}
output "kubernetes_ingress_prometheus_lb" {
  value = module.gu_kube_kandula_application.kubernetes_ingress_prometheus_lb
}
output "web_prometheus_address" {
  value = module.gu_kube_kandula_application.web_prometheus_address
}
