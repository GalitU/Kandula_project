/*
  Galit Udovik

  OpsSchool DevOps cource
  Received data from AWS
*/

/* VPC info */
output "vpc_id" {
  value = data.aws_vpc.selected.id
}
output "bastion_subnets_ids" {
  value = [for id in data.aws_subnets.bastion_subnets.ids : id]
}
output "master_subnets_ids" {
  value = [for id in data.aws_subnets.master_subnets.ids : id]
}
output "describe_kandula_mid_iam_instance_profile" {
  value = join("_", ["Role_Describe", var.application_task, var.application_name, "join"])
}
output "pub_subnets_ids" {
  value = [for id in data.aws_subnets.public.ids : id]
}
output "pvt_subnets_ids" {
  value = [for id in data.aws_subnets.private.ids : id]
}
output "sec_grp_http_ids" {
  value = [for id in data.aws_security_groups.http.ids : id]
}
output "sec_grp_https_ids" {
  value = [for id in data.aws_security_groups.https.ids : id]
}
output "sec_grp_ssh_ids" {
  value = [for id in data.aws_security_groups.ssh.ids : id]
}
output "sec_grp_consul_ids" {
  value = [for id in data.aws_security_groups.consul.ids : id]
}
output "sec_grp_jenkins_ids" {
  value = [for id in data.aws_security_groups.jenkins.ids : id]
}
output "sec_grp_bastion_ids" {
  value = [for id in data.aws_security_groups.bastion.ids : id]
}
output "data_aws_security_groups_bastion" {
  value = data.aws_security_groups.bastion
}

output "key_pair_master" {
  value = join("_", ["Key", "Master", var.application_task, var.application_name])
}
output "key_pair_bastion" {
  value = join("_", ["Key", "Bastion", var.application_task, var.application_name])
}
output "key_pair_webservers" {
  value = join("_", ["Key", "WebServers", var.application_task, var.application_name])
}
output "key_pair_consul" {
  value = join("_", ["Key", "Consul", var.application_task, var.application_name])
}
