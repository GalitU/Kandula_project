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

locals {
  jenkins_default_name      = "jenkins"
  jenkins_agent_home        = "/home/ubuntu/Jenkins"
  jenkins_tools_dir         = "${local.jenkins_agent_home}/tools"
  jenkins_tools_dir_ansible = "${local.jenkins_agent_home}/Ansible"
  jenkins_tools_dir_kubectl = "${local.jenkins_agent_home}/kubectl"
}


resource "aws_instance" "jenkins_agent" {
  count                  = var.count_instances
  ami                    = var.ami
  instance_type          = var.jenkins_instance_type
  vpc_security_group_ids = var.jenkins_sec_group_array
  key_name               = var.access_key_name
  subnet_id              = data.aws_subnets.associate_subnets_by_name_filter.ids[count.index % length(data.aws_subnets.associate_subnets_by_name_filter.ids)]
  iam_instance_profile   = var.iam_instance_profile

  connection {
    host                = self.private_ip
    user                = "ubuntu"
    private_key         = var.access_key_file
    bastion_host        = var.bastion_public_ip
    bastion_private_key = var.bastion_access_key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "mkdir ${local.jenkins_agent_home}",
      "sudo apt install software-properties-common apt-transport-https -y",
      "sudo add-apt-repository ppa:openjdk-r/ppa -y",
      "sudo apt install openjdk-8-jdk -y",
      "sudo apt install docker.io -y",
      "sudo usermod -a -G docker ubuntu",
      "sudo apt-get install awscli -y"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "aws configure set default.region ${var.aws_default_region}",
      "aws configure set aws_access_key_id ${var.aws_default_acss_key}",
      "aws configure set aws_secret_access_key ${var.aws_default_secret_key}"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo curl -o /bin/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/amd64/kubectl",
      "sudo  chmod +x /bin/kubectl"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt install software-properties-common",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y"
    ]
  }

  #provisioner "remote-exec" {
  #  inline = [
  #    "sudo docker run -d --restart=always -p 8080:8080 -p 50000:50000 -v ${local.jenkins_home_mount} -v ${local.docker_sock_mount} --env ${local.java_opts} jenkins/jenkins"
  #  ]
  #}


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
    Name                   = "${var.application_task} ${var.application_name} ${var.jenkins_purpose} ${var.jenkins_OS}_${count.index}"
    Purpose                = var.jenkins_purpose
    App_name               = var.application_name
    Task                   = var.application_task
    Owner                  = var.application_owner
    OS                     = var.jenkins_OS
    ConsulPrefixForAnsible = "${var.consul_prefix}" == "" ? "none" : "${var.consul_prefix}-${var.application_name}-${var.application_task}"
    ConsulAppDiscoveryTag  = "${var.consul_app_discovery_tag}" == "" ? "none" : "${var.consul_app_discovery_tag}"
    CreatedBy              = var.created_by
  }
}

output "jenkins_agent_id_arr" {
  value = [for ec2 in aws_instance.jenkins_agent : ec2.id]
}
output "jenkins_agent_arn" {
  value = join(", ", aws_instance.jenkins_agent[*].arn)
}
output "jenkins_agent_id" {
  value = join(", ", aws_instance.jenkins_agent[*].id)
}
output "jenkins_agent_dns" {
  value = join(", ", aws_instance.jenkins_agent[*].public_dns)
}
locals {
  pvt_ip_arr = join(" = jenkins_pvt_ip_address\n", aws_instance.jenkins_agent[*].private_ip)
}
output "jenkins_agent_private_ips" {
  value = "\n${local.pvt_ip_arr} = jenkins_pvt_ip_address\n"
}
output "jenkins_agent_public_ips" {
  value = join(", ", aws_instance.jenkins_agent[*].public_ip)
}
