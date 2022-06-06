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
  jenkins_default_name = "jenkins"
  jenkins_home         = "/home/ubuntu/jenkins_home"
  jenkins_home_mount   = "${local.jenkins_home}:/var/jenkins_home"
  docker_sock_mount    = "/var/run/docker.sock:/var/run/docker.sock"
  java_opts            = "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"
}


resource "aws_instance" "jenkins_server" {
  ami                         = var.ami
  instance_type               = var.jenkins_instance_type
  vpc_security_group_ids      = var.jenkins_sec_group_array
  key_name                    = var.access_key_name
  subnet_id                   = data.aws_subnets.associate_subnets_by_name_filter.ids[0]
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = var.iam_instance_profile

  connection {
    host                = aws_instance.jenkins_server.private_ip
    user                = "ubuntu"
    private_key         = var.access_key_file
    bastion_host        = var.bastion_public_ip
    bastion_private_key = var.bastion_access_key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt install docker.io -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      "mkdir -p ${local.jenkins_home}",
      "sudo chown -R 1000:1000 ${local.jenkins_home}"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker run -d --restart=always -p 8080:8080 -p 50000:50000 -v ${local.jenkins_home_mount} -v ${local.docker_sock_mount} --env ${local.java_opts} jenkins/jenkins"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt install awscli"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo curl -o ${local.jenkins_home}/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/amd64/kubectl",
      "sudo  chmod +x ${local.jenkins_home}/kubectl",
    ]
  }

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
    Name                   = "${var.application_task} ${var.application_name} ${var.jenkins_purpose} ${var.jenkins_OS}"
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
output "jenkins_servers_id_arr" {
  value = [aws_instance.jenkins_server.id]
}
output "jenkins_servers_arn" {
  value = join(", ", aws_instance.jenkins_server[*].arn)
}
output "jenkins_servers_id" {
  value = join(", ", aws_instance.jenkins_server[*].id)
}
output "jenkins_servers_dns" {
  value = join(", ", aws_instance.jenkins_server[*].public_dns)
}
output "jenkins_servers_private_ips" {
  value = join(", ", aws_instance.jenkins_server[*].private_ip)
}
output "jenkins_servers_public_ips" {
  value = join(", ", aws_instance.jenkins_server[*].public_ip)
}
