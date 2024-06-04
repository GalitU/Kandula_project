
output "kandula_app_namespace_name" {
  value = data.kubernetes_namespace_v1.kandula_app_namespace.metadata[0].name
}
output "kubernetes_deployment_name" {
  value = kubernetes_deployment_v1.kandula_app_deploy.metadata[0].name
}
output "kubernetes_service_name" {
  value = kubernetes_service_v1.kandula_svc.metadata[0].name
}
output "kubernetes_ingress_name" {
  value = kubernetes_ingress.kandula_ingress.metadata[0].name
}
output "kubernetes_ingress_grafana_name" {
  value = kubernetes_ingress.grafana_ingress.metadata[0].name
}
output "kubernetes_ingress_prometheus_name" {
  value = kubernetes_ingress.prometheus_ingress.metadata[0].name
}
output "kubernetes_ingress_lb" {
  value = kubernetes_ingress.kandula_ingress.status.0.load_balancer.0.ingress.0.hostname
}
output "kubernetes_ingress_grafana_lb" {
  value = kubernetes_ingress.grafana_ingress.status.0.load_balancer.0.ingress.0.hostname
}
output "kubernetes_ingress_prometheus_lb" {
  value = kubernetes_ingress.prometheus_ingress.status.0.load_balancer.0.ingress.0.hostname
}
output "aws_acm_certificate" {
  value = data.aws_acm_certificate.compoze_acm.arn
}
output "web_kandula_address" {
  value = join("", ["https://", aws_route53_record.kandula.name, ".galitu.site"])
}
output "web_grafana_address" {
  value = join("", ["https://", aws_route53_record.grafana_record_53.name, ".galitu.site"])
}
output "web_prometheus_address" {
  value = join("", ["https://", aws_route53_record.prometheus_record_53.name, ".galitu.site"])
}
