output "pub_subnets" {
  value = aws_subnet.pub_subnet
}
output "pvt_subnets" {
  value = aws_subnet.pvt_subnet
}
output "sec_grp_http" {
  value = aws_security_group.sec_grp_http
}
output "sec_grp_https" {
  value = aws_security_group.sec_grp_https
}
output "jenkins_sec_grp_http" {
  value = aws_security_group.jenkins_sec_grp_http
}
output "sec_grp_ssh" {
  value = aws_security_group.sec_grp_ssh
}
output "sec_grp_consul" {
  value = aws_security_group.consul_sg
}
output "sec_grp_consul_ui" {
  value = aws_security_group.consul_sg_server_ui
}
output "sec_grp_kube" {
  value = aws_security_group.kubernetes_sec_grp_http
}
output "sec_group_bastion_ssh" {
  value = aws_security_group.bastion_sec_grp_ssh
}
output "sec_grp_monitoring" {
  value = aws_security_group.monitor_sg
}
output "sec_grp_monitoring_ui" {
  value = aws_security_group.grafana_prometheus
}
output "sec_grp_node_exporter" {
  value = aws_security_group.node_exporter_sg
}
output "aws_acm_certificate_id" {
  value = aws_acm_certificate.compoze_acm.id
}
output "aws_acm_certificate_arn" {
  value = aws_acm_certificate.compoze_acm.arn
}
output "vpc_id" {
  value = aws_vpc.vpc.id
}
