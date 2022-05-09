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
  value = join(",\n", module.vpc.pub_subnets[*].cidr_block)
}
output "vpc_pvt-subnet" {
  value = join(",\n", module.vpc.pvt_subnets[*].cidr_block)
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
  value = join(",\n",
    [
      module.key_credentials_consul.private_key_file_with_path,
      module.key_credentials_bastion.private_key_file_with_path,
      module.key_credentials_master.private_key_file_with_path,
      module.key_credentials_webserver.private_key_file_with_path
  ])
}
output "private_key_names" {
  value = join(",\n",
    [
      module.key_credentials_consul.private_key_name,
      module.key_credentials_bastion.private_key_name,
      module.key_credentials_master.private_key_name,
      module.key_credentials_webserver.private_key_name
  ])
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
output "cosul_alb_dns" {
  value = module.consul_server_load_balancers.alb_dns
}
#output "webservers_worker_alb_dns" {
#  value = module.webserver_workers_load_balancers.alb_dns
#}

/* Consul server output */
output "ec2_consul_servers_arn" {
  value = module.ec2_consul_servers.ec2_servers_arn
}
output "ec2_consul_servers_id" {
  value = module.ec2_consul_servers.ec2_servers_id
}
output "ec2_consul_servers_dns" {
  value = module.ec2_consul_servers.ec2_servers_dns
}
output "ec2_consul_servers_private_ip" {
  value = module.ec2_consul_servers.ec2_servers_private_ips
}
/* Consul agent output */
output "jenkins_slaves_arn" {
  value = module.jenkins_slaves.ec2_servers_arn
}
output "jenkins_slaves_id" {
  value = module.jenkins_slaves.ec2_servers_id
}
output "jenkins_slaves_dns" {
  value = module.jenkins_slaves.ec2_servers_dns
}
output "jenkins_slaves_private_ip" {
  value = module.jenkins_slaves.ec2_servers_private_ips
}
/* Bastion output */
output "bastion_server_arn" {
  value = module.bastion_server.bastion_server_arn
}
output "bastion_server_id" {
  value = module.bastion_server.bastion_server_id
}
output "bastion_server_dns" {
  value = module.bastion_server.bastion_server_dns
}
output "bastion_server_private_ip" {
  value = module.bastion_server.bastion_server_private_ip
}
output "bastion_server_public_ip" {
  value = module.bastion_server.bastion_server_public_ip
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
##@@##   /* Kubernetes */
##@@##   output "kube_cluster_id" {
##@@##     description = "EKS cluster ID."
##@@##     value       = module.kubernetes.cluster_id
##@@##   }
##@@##   output "kube_cluster_endpoint" {
##@@##     description = "Endpoint for EKS control plane."
##@@##     value       =  module.kubernetes.cluster_endpoint
##@@##   }
##@@##   output "kube_cluster_security_group_id" {
##@@##     description = "Security group ids attached to the cluster control plane."
##@@##     value       = module.kubernetes.cluster_security_group_id
##@@##   }
##@@##   output "kube_cluster_name" {
##@@##     value       = module.kubernetes.cluster_name
##@@##   }
##@@##   output "kube_oidc_provider_arn" {
##@@##     value =module.kubernetes.oidc_provider_arn
##@@##   }
