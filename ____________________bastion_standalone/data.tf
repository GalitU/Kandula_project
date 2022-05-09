/*
  Galit Udovik

  OpsSchool DevOps cource
  Received data from AWS
*/



/*
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "template_file" "consul_server_setup_script" {
  template = templatefile("${path.module}/../../modules/scripts/consule-server.sh",
    {
      CONSUL_VERSION = "1.8.5"
      CONSUL_TAG_NAME = "ConsulTag",
      CONSUL_TAG_VALUE = "Consul-${var.application_name}-${var.application_task}"
    }
  )
}

data "template_file" "consul_agent_setup_script" {
  template = templatefile("${path.module}/../../modules/scripts/consule-agent.sh",
    {
      CONSUL_VERSION = "1.8.5"
      CONSUL_TAG_NAME = "ConsulTag",
      CONSUL_TAG_VALUE = "Consul-${var.application_name}-${var.application_task}"
    }
  )
}

data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "pub_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = {
    Purpose = "Bastion"
    Tier = "Public"
  }
}

data "aws_subnet" "pub_subnet" {
  for_each = toset(data.aws_subnets.pub_subnets.ids)
  id       = each.value
}

data "aws_iam_roles" "describe_kandula_mid_role" {
  name_regex = "Role_Assume_Describe_Kandula_MPrj_join"
}
*/
