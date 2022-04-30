/*
  Galit Udovik

  OpsSchool DevOps cource
  Servers configuration
*/

data "aws_subnets" "associate_subnets_by_name_filter" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Tier"
    values = [var.type_of_subnet]
  }

  filter {
    name   = "tag:Purpose"
    values = [var.subnet_association_tag]
  }
}

resource "aws_instance" "ec2_server" {
  ami                         = var.ami
  instance_type               = var.ec2_instance_type
  count                       = var.count_instances
  user_data                   = var.user_data_file
  vpc_security_group_ids      = var.ec2_sec_group_array
  key_name                    = var.access_key_name
  subnet_id                   = data.aws_subnets.associate_subnets_by_name_filter.ids[count.index % length(data.aws_subnets.associate_subnets_by_name_filter.ids)]
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = var.iam_instance_profile

  # Root decrypted disk
  root_block_device {
    volume_size           = var.disk_size
    volume_type           = var.disk_type
    delete_on_termination = true
    encrypted             = false
  }

  # External encrypted disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.disk_size
    volume_type           = var.disk_type
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name      = "${var.application_task} ${var.application_name} ${var.ec2_purpose} ${var.ec2_OS}_${count.index}"
    Purpose   = var.ec2_purpose
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    OS        = var.ec2_OS
    ConsulTag = "Consul-${var.application_name}-${var.application_task}"
    CreatedBy = var.created_by
  }
}
output "ec2_servers_id_arr" {
  value = [for ec2 in aws_instance.ec2_server : ec2.id]
}
output "ec2_servers_arn" {
  value = join(", ", aws_instance.ec2_server[*].arn)
}
output "ec2_servers_id" {
  value = join(", ", aws_instance.ec2_server[*].id)
}
output "ec2_servers_dns" {
  value = join(", ", aws_instance.ec2_server[*].public_dns)
}
output "ec2_servers_private_ips" {
  value = join(", ", aws_instance.ec2_server[*].private_ip)
}
output "user_data_file" {
  value = var.user_data_file
}
