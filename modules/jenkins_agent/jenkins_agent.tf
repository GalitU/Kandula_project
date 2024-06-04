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
  jenkins_default_name                   = "jenkins"
  jenkins_agent_home                     = "/home/ubuntu/Jenkins"
  jenkins_tools_dir                      = "${local.jenkins_agent_home}/tools"
  jenkins_tools_dir_ansible              = "${local.jenkins_agent_home}/Ansible"
  jenkins_tools_dir_kubectl              = "${local.jenkins_agent_home}/kubectl"
  jenkins_tools_dir_jenkins_registration = "${local.jenkins_agent_home}/jenkins_registration"
}

data "aws_instance" "jenkins_srv" {
  instance_tags = {
    Purpose  = "JenkinsSrv"
    Task     = var.application_task
    App_name = var.application_name
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

locals {
  #jenkins_server_url = "http://${data.aws_instance.jenkins_srv.private_ip}:8080"
  jenkins_server_url = "https://jenkins.galitu.site"
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
      "mkdir ${local.jenkins_tools_dir_jenkins_registration}",
      "sudo apt install software-properties-common apt-transport-https -y",
      "sudo add-apt-repository ppa:openjdk-r/ppa -y",
      "sudo apt install openjdk-8-jdk -y",
      "sudo apt install docker.io -y",
      "sudo usermod -a -G docker ubuntu",
      "sudo apt-get install python3 -y",
      "sudo apt-get install python3-pip -y",
      "sudo pip3 install boto boto3 click",
      "sudo apt-get install awscli -y",
      "sudo pip3 install --upgrade awscli",
      "sudo apt-get install wget apt-transport-https gnupg lsb-release -y",
      "wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -",
      "echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list",
      "sudo apt-get update",
      "sudo apt-get install trivy"
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

  provisioner "file" {
    source      = "${path.module}/jenkins_agent_key.pub"
    destination = "${local.jenkins_tools_dir_jenkins_registration}/jenkins_agent_key.pub"
  }
  provisioner "remote-exec" {
    inline = [
      "cat ${local.jenkins_tools_dir_jenkins_registration}/jenkins_agent_key.pub >> ~/.ssh/authorized_keys"
    ]
  }

  # Self registration into jenkins server
  provisioner "file" {
    source      = "${path.module}/jenkins_node_add.j2"
    destination = "${local.jenkins_tools_dir_jenkins_registration}/jenkins_node_add.tmpl"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo wget -O ${local.jenkins_tools_dir_jenkins_registration}/jenkins-cli.jar --no-check-certificate ${local.jenkins_server_url}/jnlpJars/jenkins-cli.jar",
      "sudo echo ${self.private_ip} > ${local.jenkins_tools_dir_jenkins_registration}/seft_private_ip.txt",
      "export SLAVE_NAME=`cat Jenkins/jenkins_registration/seft_private_ip.txt`",
      "envsubst < ${local.jenkins_tools_dir_jenkins_registration}/jenkins_node_add.tmpl > ${local.jenkins_tools_dir_jenkins_registration}/jenkins_node_add.xml",
      "cat ${local.jenkins_tools_dir_jenkins_registration}/jenkins_node_add.xml | java -jar ${local.jenkins_tools_dir_jenkins_registration}/jenkins-cli.jar -s ${local.jenkins_server_url} -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -webSocket create-node JenkinsAgent_$SLAVE_NAME",
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
    Name                   = "${var.application_task}-${var.application_name}-${var.jenkins_purpose}-${var.jenkins_OS}-${count.index}"
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

# Output relevant data
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
