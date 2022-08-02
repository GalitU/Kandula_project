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
  value = module.gu_reguest_data.vpc_id
}

/* Roles of jenkins server */
output "role_jenkins_server" {
  value = module.gu_iam_roles_describe_jenkins_server.role
}
output "role_policy_jenkins_server" {
  value = module.gu_iam_roles_describe_jenkins_server.role_policy
}
output "iam_role_name_jenkins_server" {
  value = module.gu_iam_roles_describe_jenkins_server.iam_role_name
}

/* Roles jenkins agent */
output "role_jenkins_agent" {
  value = module.gu_iam_roles_describe_jenkins_agent.role
}
output "role_policy_jenkins_agent" {
  value = module.gu_iam_roles_describe_jenkins_agent.role_policy
}
output "iam_role_name_jenkins_agent" {
  value = module.gu_iam_roles_describe_jenkins_agent.iam_role_name
}

/* Load balancers */
output "jenkins_alb_dns" {
  value = module.gu_jenkins_server_load_balancers.alb_dns
}
output "jenkins_http_address" {
  value = "https://${module.gu_route53.hosted_zone_record_fqdn}"
}
/* Jenkins
 agent output */
output "jenkins_slaves_arn" {
  value = module.gu_jenkins_agent.jenkins_agent_arn
}
output "jenkins_slaves_id" {
  value = module.gu_jenkins_agent.jenkins_agent_id
}
output "jenkins_slaves_dns" {
  value = module.gu_jenkins_agent.jenkins_agent_dns
}
output "jenkins_slaves_private_ip" {
  value = module.gu_jenkins_agent.jenkins_agent_private_ips
}
/* Jenkins output */
output "jenkins_server_arn" {
  value = module.gu_jenkins_server.jenkins_servers_arn
}
output "jenkins_server_id" {
  value = module.gu_jenkins_server.jenkins_servers_id
}
output "jenkins_server_dns" {
  value = module.gu_jenkins_server.jenkins_servers_dns
}
output "jenkins_server_private_ip" {
  value = module.gu_jenkins_server.jenkins_servers_private_ips
}
