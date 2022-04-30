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
  value = module.vpc.vpc_id
}
output "vpc_pub-subnet" {
  value = join(", ", module.vpc.pub_subnets[*].cidr_block)
}
output "vpc_pvt-subnet" {
  value = join(", ", module.vpc.pvt_subnets[*].cidr_block)
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

/* Keys */
output "private_key_files_with_path" {
  value = join(", ",
    [
      module.key_credentials_consul.private_key_file_with_path,
      module.key_credentials_bastion.private_key_file_with_path,
      module.key_credentials_ansible.private_key_file_with_path
  ])
}
output "private_key_names" {
  value = join(", ",
    [
      module.key_credentials_consul.private_key_name,
      module.key_credentials_bastion.private_key_name,
      module.key_credentials_ansible.private_key_name
  ])
}

/* Roles */
output "role" {
  value = module.iam_roles_describe.role
}
output "role_policy" {
  value = module.iam_roles_describe.role_policy
}

##### /* Load balancers */
##### output "cosul_alb_dns" {
#####   value = module.load_balancers.cosul_alb_dns
##### }
##### output "ec2_alb_dns" {
#####   value = module.load_balancers.ec2_alb_dns
##### }
#####
##### /* Consul output */
##### output "ec2_consul_servers_arn" {
#####   value = module.ec2_consul_servers.ec2_servers_arn
##### }
##### output "ec2_consul_servers_id" {
#####   value = module.ec2_consul_servers.ec2_servers_id
##### }
##### output "ec2_consul_servers_dns" {
#####   value = module.ec2_consul_servers.ec2_servers_dns
##### }
##### output "ec2_consul_servers_private_ip" {
#####   value = module.ec2_consul_servers.ec2_servers_private_ips
##### }
/* Consul agent output */
output "ec2_web_servers_arn" {
  value = module.ec2_web_servers.ec2_servers_arn
}
output "ec2_web_servers_id" {
  value = module.ec2_web_servers.ec2_servers_id
}
output "ec2_web_servers_dns" {
  value = module.ec2_web_servers.ec2_servers_dns
}
output "ec2_web_servers_private_ip" {
  value = module.ec2_web_servers.ec2_servers_private_ips
}
/* Bastion output */
output "ec2_bastion_server_arn" {
  value = module.ec2_bastion_server.ec2_servers_arn
}
output "ec2_bastion_server_id" {
  value = module.ec2_bastion_server.ec2_servers_id
}
output "ec2_bastion_server_dns" {
  value = module.ec2_bastion_server.ec2_servers_dns
}
output "ec2_bastion_server_private_ip" {
  value = module.ec2_bastion_server.ec2_servers_private_ips
}
/* Ansible output */
output "ec2_ansible_server_arn" {
  value = module.ec2_ansible_server.ec2_servers_arn
}
output "ec2_ansible_server_id" {
  value = module.ec2_ansible_server.ec2_servers_id
}
output "ec2_ansible_server_dns" {
  value = module.ec2_ansible_server.ec2_servers_dns
}
output "ec2_ansible_server_private_ip" {
  value = module.ec2_ansible_server.ec2_servers_private_ips
}
