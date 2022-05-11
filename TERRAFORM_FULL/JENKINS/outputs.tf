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

/* Roles */
output "role" {
  value = module.iam_roles_describe.role
}
output "role_policy" {
  value = module.iam_roles_describe.role_policy
}

output "iam_role_join_name" {
  value = module.iam_roles_describe.iam_role_join_name
}
/* Load balancers */
output "jenkins_alb_dns" {
  value = module.jenkins_server_load_balancers.alb_dns
}
/* Jenkins
 agent output */
output "jenkins_slaves_arn" {
  value = module.jenkins_agent.jenkins_agent_arn
}
output "jenkins_slaves_id" {
  value = module.jenkins_agent.jenkins_agent_id
}
output "jenkins_slaves_dns" {
  value = module.jenkins_agent.jenkins_agent_dns
}
output "jenkins_slaves_private_ip" {
  value = module.jenkins_agent.jenkins_agent_private_ips
}
/* Jenkins output */
output "jenkins_server_arn" {
  value = module.jenkins_server.jenkins_servers_arn
}
output "jenkins_server_id" {
  value = module.jenkins_server.jenkins_servers_id
}
output "jenkins_server_dns" {
  value = module.jenkins_server.jenkins_servers_dns
}
output "jenkins_server_private_ip" {
  value = module.jenkins_server.jenkins_servers_private_ips
}
