/*
  Galit Udovik

  OpsSchool DevOps cource
  Create VPC and subnets here
*/

data "aws_availability_zones" "active" {
  state = "available"
}

locals {
  az = slice(data.aws_availability_zones.active.*.names[0], 0, 2)
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name      = "VPC-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_subnet" "pub_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "true" //it makes this a public subnet
  count                   = length(var.cidr_block_pub)
  availability_zone       = local.az[count.index % length(local.az)]
  cidr_block              = var.cidr_block_pub[count.index]
  tags = {
    Tier      = "Public"
    Name      = "Pub-subnet-${var.subnet_pub_prefix_template_arr[count.index]}-${count.index + 1}-${lower(var.application_name)}-${var.application_task}"
    Purpose   = var.subnet_pub_prefix_template_arr[count.index]
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_subnet" "pvt_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "false" //it makes this a private subnet
  count                   = length(var.cidr_block_pvt)
  availability_zone       = local.az[count.index % length(local.az)]
  cidr_block              = var.cidr_block_pvt[count.index]
  tags = {
    Tier      = "Private"
    Name      = "Pvt-subnet--${var.subnet_pvt_prefix_template_arr[count.index]}-${count.index + 1}-${lower(var.application_name)}-${var.application_task}"
    Purpose   = var.subnet_pvt_prefix_template_arr[count.index]
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}
