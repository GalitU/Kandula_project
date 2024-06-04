locals {
  abs_path_to_keys    = abspath(path.module)
  bastion_key         = module.gu_reguest_data.key_pair_bastion
  path_to_keys        = "${local.abs_path_to_keys}/../KEYS/"
  path_to_bastion_key = "${local.abs_path_to_keys}/../KEYS/${local.bastion_key}.pem"
}

data "aws_instance" "bastion" {
  depends_on = [module.gu_bastion_server]
  instance_tags = {
    Purpose  = "Bastion"
    Task     = var.application_task
    App_name = var.application_name
  }
  filter {
    name   = "vpc-id"
    values = [module.gu_reguest_data.vpc_id]
  }
}

data "template_file" "config_ssh" {
  depends_on = [module.gu_bastion_server]
  template = file("${path.module}/config.j2")
  vars = {
    BASTION_PUBLIC_IP   = module.gu_bastion_server.bastion_server_public_ip
  }
}

resource "null_resource" "update_ssh_config_file" {
  depends_on = [module.gu_bastion_server, data.template_file.config_ssh]

  provisioner "local-exec" {
    command = "echo \"${data.template_file.config_ssh.rendered}\" > ${path.module}/config"
  }
 provisioner "local-exec" {
    command = "chmod 644 ${path.module}/config"
  }
  provisioner "local-exec" {
    command = "cp ${path.module}/config ~/.ssh/config"
  }
}

resource "null_resource" "bastion_update_pub_key" {
  depends_on = [module.gu_bastion_server, null_resource.update_ssh_config_file]

  connection {
    host                = module.gu_bastion_server.bastion_server_private_ip
    user                = "ubuntu"
    private_key         = file(local.path_to_bastion_key)
    bastion_host        = data.aws_instance.bastion.public_ip
    bastion_private_key = file(local.path_to_bastion_key)
  }

  provisioner "remote-exec" {
    inline = [
      "echo \"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrQe20EN5U2aBkD0NEGBWPb9b4OeTof/yfsh/dLgdfwu2D7SGBxwGt4JLOiT0XgW4z2cuH5WUu4xe9e+jGDxYztP+zKtqSSYYE++1NREzA5aDgn8GX792+oxlkpeVddpUFPUK2qEXPsBHbJ5T5hNspqzeYhU6syxaJrIVd0CYu0SFiGrA2QDiMNPn/Q5z5IQSRsCarcBO8NKets47l9WKzCcBrL1xalOUcjz1rp5th25LsoBHpAZaGY1Ipm2iYhaXAx06sJDa+6jPnO/YZyEybldJAmrVZXCww2emtlV5VagzLae/T6GO+0dXTBruuksySzg7pgzdq8b3vhMutNq+rADaWtOMZZWM8FR4KYE8IVSMi6bv9Z63hivfhoPwh9+q1iePzQnmn922VdnzjL/t8ahU2udydwfGHXwLl75XEBnnWQSfZO9oMbxjfwR7KOMepESme4PBp1H4MB2feBUisX3Hd3PQ4111DyYUdAmZE96TaLJQEDGhOz0fIPZi7M+c= ubuntu@ip-10-0-4-214\" > ~/ansible_key.pub",
      "cat ~/ansible_key.pub >> ~/.ssh/authorized_keys"
    ]
  }

/*
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt install software-properties-common",
      "sudo apt-get install python3 -y",
      "sudo apt-get install python3-pip -y",
      "sudo pip3 install boto boto3 click"
    ]
  }
  */
}
