/*
  Galit Udovik

  OpsSchool DevOps cource
  Received data from AWS
*/

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "template_file" "consul_server_setup_script" {
  template = templatefile("${path.module}/../../modules/scripts/consule-server.sh",
    {
      CONSUL_VERSION   = "1.8.5"
      CONSUL_TAG_NAME  = "ConsulTag",
      CONSUL_TAG_VALUE = "Consul-${var.application_name}-${var.application_task}"
    }
  )
}

data "template_file" "consul_agent_setup_script" {
  template = templatefile("${path.module}/../../modules/scripts/consule-agent.sh",
    {
      CONSUL_VERSION   = "1.8.5"
      CONSUL_TAG_NAME  = "ConsulTag",
      CONSUL_TAG_VALUE = "Consul-${var.application_name}-${var.application_task}"
    }
  )
}

/*
data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc_name
  }
}
*/
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "bastion_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Purpose  = "Bastion"
    Tier     = "Public"
    Task     = var.application_task
    App_name = var.application_name
  }
}

data "aws_subnets" "master_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Purpose  = "Master"
    Tier     = "Private"
    Task     = var.application_task
    App_name = var.application_name
  }
}
data "aws_subnets" "workers_pvt_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Purpose  = "WebServers"
    Tier     = "Private"
    Task     = var.application_task
    App_name = var.application_name
  }
}

/*
data "aws_iam_instance_profile" "describe_kandula_fin_role" {
  name_regex = "Role_Assume_Describe_Kandula_FPrj_join"
}
*/
#data "aws_iam_instance_profile" "describe_kandula_fin_role" {
#  name = join("_", ["Role_Describe", var.application_task, var.application_name, "join"])
#}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Tier     = "Public"
    Task     = var.application_task
    App_name = var.application_name
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Tier     = "Private"
    Task     = "Kandula"
    App_name = "FPrj"
  }
}

data "aws_security_groups" "http" {
  tags = {
    Type     = "HTTP"
    Task     = var.application_task
    App_name = var.application_name
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_security_groups" "https" {
  tags = {
    Type     = "HTTPS"
    Task     = var.application_task
    App_name = var.application_name
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_security_groups" "ssh" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Type     = "SSH"
    Name     = "SG_SSH-${lower(var.application_name)}-${var.application_task}"
    Task     = var.application_task
    App_name = var.application_name
  }
}

data "aws_security_groups" "jenkins" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Type     = "Jenkins"
    Name     = "SG_Jenkins-${lower(var.application_name)}-${var.application_task}"
    Task     = var.application_task
    App_name = var.application_name
  }
}

data "aws_security_groups" "consul_ui" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Type     = "Consul"
    Name     = "SG_Consul-UI-${lower(var.application_name)}-${var.application_task}"
    Task     = var.application_task
    App_name = var.application_name
  }
}

data "aws_security_groups" "consul" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Type     = "Consul"
    Name     = "SG_Consul-${lower(var.application_name)}-${var.application_task}"
    Task     = var.application_task
    App_name = var.application_name
  }
}

data "aws_security_groups" "bastion" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Type     = "SSH"
    Name     = "SG_Bastion_SSH-${lower(var.application_name)}-${var.application_task}"
    Task     = var.application_task
    App_name = var.application_name
  }
}

data "aws_route53_zone" "hosted_zone_53" {
  name         = var.route53_host_zone_name
  private_zone = false
}


data "aws_security_groups" "sec_grp_kube" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Type     = "Kubernetes"
    Name     = "SG_Kube_worker-${lower(var.application_name)}-${var.application_task}"
    Task     = var.application_task
    App_name = var.application_name
  }
}
data "aws_security_groups" "sec_grp_monitoring" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Type     = "Monitoring"
    Name     = "SG_monitor-${lower(var.application_name)}-${var.application_task}"
    Task     = var.application_task
    App_name = var.application_name
  }
}

data "aws_security_groups" "sec_grp_monitoring_ui" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Type     = "Monitoring"
    Name     = "SG_monitor_ui-${lower(var.application_name)}-${var.application_task}"
    Task     = var.application_task
    App_name = var.application_name
  }
}
data "aws_security_groups" "sec_grp_node_exporter" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Type     = "Monitoring"
    Name     = "SG_Node_Exporter-${lower(var.application_name)}-${var.application_task}"
    Task     = var.application_task
    App_name = var.application_name
  }
}

data "aws_security_groups" "sec_grp_elk_server" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Type      = "ELK"
    Name      = "SG_EKL-${lower(var.application_name)}-${var.application_task}"
    Task     = var.application_task
    App_name = var.application_name
  }
}

data "aws_acm_certificate" "compoze_acm" {
  domain   = "*.galitu.site"
  statuses = ["ISSUED"]
}

locals {
  cluster_name = "kandula-prj-kube"
}

/*
data "aws_lb" "lb_monitoring" {
  name = "LB-monitoring-fprj-Kandula"
}


data "aws_lb" "lb_consul" {
  name = "LB-consul-fprj-Kandula"
}


data "aws_lb" "lb_jenkins" {
  name = "LB-jenkins-fprj-Kandula"
}
*/
