# Update public key
resource "null_resource" "update_pub_key" {
  count      = var.count_instances
  depends_on = [module.gu_ec2_elk, module.gu_elk_server_load_balancers]

  connection {
    host                = module.gu_ec2_elk.ec2_servers_private_ips_arr[count.index]
    user                = "ubuntu"
    private_key         = file(local.path_to_elk_key)
    bastion_host        = data.aws_instance.bastion.public_ip
    bastion_private_key = file(local.path_to_bastion_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo lsof /var/lib/dpkg/lock",
      "sudo lsof /var/lib/apt/lists/lock",
      "sudo lsof /var/cache/apt/archives/lock",
      "sudo lsof /var/lib/dpkg/lock-frontend",
      "sudo dpkg --configure -a",
      "echo \"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrQe20EN5U2aBkD0NEGBWPb9b4OeTof/yfsh/dLgdfwu2D7SGBxwGt4JLOiT0XgW4z2cuH5WUu4xe9e+jGDxYztP+zKtqSSYYE++1NREzA5aDgn8GX792+oxlkpeVddpUFPUK2qEXPsBHbJ5T5hNspqzeYhU6syxaJrIVd0CYu0SFiGrA2QDiMNPn/Q5z5IQSRsCarcBO8NKets47l9WKzCcBrL1xalOUcjz1rp5th25LsoBHpAZaGY1Ipm2iYhaXAx06sJDa+6jPnO/YZyEybldJAmrVZXCww2emtlV5VagzLae/T6GO+0dXTBruuksySzg7pgzdq8b3vhMutNq+rADaWtOMZZWM8FR4KYE8IVSMi6bv9Z63hivfhoPwh9+q1iePzQnmn922VdnzjL/t8ahU2udydwfGHXwLl75XEBnnWQSfZO9oMbxjfwR7KOMepESme4PBp1H4MB2feBUisX3Hd3PQ4111DyYUdAmZE96TaLJQEDGhOz0fIPZi7M+c= ubuntu@ip-10-0-4-214\" > ~/ansible_key.pub",
      "cat ~/ansible_key.pub >> ~/.ssh/authorized_keys"
    ]
  }
}

resource "null_resource" "install_python" {
  count      = var.count_instances
  depends_on = [null_resource.update_pub_key]

  connection {
    host                = module.gu_ec2_elk.ec2_servers_private_ips_arr[count.index]
    user                = "ubuntu"
    private_key         = file(local.path_to_elk_key)
    bastion_host        = data.aws_instance.bastion.public_ip
    bastion_private_key = file(local.path_to_bastion_key)
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt install software-properties-common",
      "sudo apt-get install python3 -y",
      "sudo apt-get install python3-pip -y",
      "sudo pip3 install boto boto3 click"
    ]
  }
}

resource "null_resource" "install_elasticsearch" {
  count      = var.count_instances
  depends_on = [null_resource.install_python]

  connection {
    host                = module.gu_ec2_elk.ec2_servers_private_ips_arr[count.index]
    user                = "ubuntu"
    private_key         = file(local.path_to_elk_key)
    bastion_host        = data.aws_instance.bastion.public_ip
    bastion_private_key = file(local.path_to_bastion_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname \"ELKSrv\"",
      "sudo apt update -y && sudo apt upgrade -y",
      "sudo apt install default-jdk -y",
      "sudo apt-get install apt-transport-https",
      "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
      "echo \"deb https://artifacts.elastic.co/packages/7.x/apt stable main\" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list",
      "sudo apt update -y",
      "sudo apt install elasticsearch -y",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable elasticsearch",
      "sudo systemctl start elasticsearch",
      #"sudo systemctl status elasticsearch"
    ]
  }
}

resource "null_resource" "install_kibana" {
  count      = var.count_instances
  depends_on = [null_resource.install_elasticsearch]

  connection {
    host                = module.gu_ec2_elk.ec2_servers_private_ips_arr[count.index]
    user                = "ubuntu"
    private_key         = file(local.path_to_elk_key)
    bastion_host        = data.aws_instance.bastion.public_ip
    bastion_private_key = file(local.path_to_bastion_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt install kibana -y",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable kibana",
      "sudo systemctl start kibana",
      "sudo systemctl stop kibana",
      "sudo rm /etc/kibana/kibana.yml",
      #"sudo systemctl status kibana",
      "sudo echo 'server.port: 5601' | sudo tee -a /etc/kibana/kibana.yml",
      "sudo echo 'server.host: 0.0.0.0' | sudo tee -a /etc/kibana/kibana.yml",
      "sudo systemctl restart kibana",
    ]
  }
}
