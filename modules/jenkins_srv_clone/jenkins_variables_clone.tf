/*
  Galit Udovik

  OpsSchool DevOps cource
  File with declaration of variables for web servers
*/

variable "region" {
  description = "Region where the infrastructure will be created"
  type        = string
}
variable "vpc_id" {
  description = "Vpc id"
}
variable "jenkins_instance_type" {
  description = "Type of instance machine"
  default     = "t3.medium"
}
variable "ami" {
  description = "Image type of instance"
  default     = "ami-0cf8ed9f497b9ec43"
  #"ami-0d89aa3854b1a7dbc"
  #"ami-0ec36101b659f943b"
  #"ami-085b996391f9763f7"
  #"ami-060e1eef0fbca523b"
  #"ami-0125ff874400eff56"
  #"ami-054bdd10d6b146b25"
  #"ami-0971deea0ac0124ba"
  #"ami-0a1b1df5f1c65f142"
  #"ami-034b4a9c1f4410e4b"
  #"ami-0b849cfa9a28db221"
  #"ami-034e58071690a6a33"
  #"ami-0f5afe30fc3f654e9"
  #"ami-0afb069da06d8a56f"
  #"ami-0575d4d9d5f0f8d32"
  #"ami-00b90dac46bce4b7a"
  #"ami-04884824bab8563b8"
  #"ami-02aaedf8e0af1c0c3" Vers #1
  # Uses my Jenkins inatalled AMI, next is AMI of regular UBUNTU 21.04 "ami-0d527b8c289b4af7f"
}
variable "count_instances" {
  description = "Count of instances"
  default     = 1
}
variable "subnet_association_tag" {
  description = "For filter relevant subnets"
}
variable "jenkins_sec_group_array" {
  description = "List of relevant security groups for web instances"
  type        = list(string)
}
variable "type_of_subnet" {
  description = "Public or Private for type of subnet"
}
variable "disk_size" {
  description = "Size of disks on instance"
  default     = 10
}
variable "disk_type" {
  description = "Type of storage disk of instances"
  default     = "gp2"
}

variable "application_name" {
  description = "Application name"
}
variable "application_task" {
  description = "Name of envinronment"
}
variable "consul_prefix" {
  description = "Consul prefix for ansible, will be relevant for any consul service(ConsulSrv, ConsulAgent)"
}
variable "consul_app_discovery_tag" {
  description = "Discovery tag for consul application"
}
variable "created_by" {
  description = "Create manually or by terraform"
}
variable "application_owner" {
  description = "Owner name"
  default     = "Galit Udovik"
}
variable "jenkins_purpose" {
  description = "jenkins purpose"
  type        = string
}
variable "jenkins_OS" {
  description = "OS of Operating system"
  type        = string
}
variable "access_key_name" {
  description = "Name of key for access via SSH"
}
variable "s3_bucket_name_for_log" {
  type    = string
  default = "s3-log-ops-bucket"
}
variable "iam_instance_profile" {
  description = "Role info profiler for jenkins instance"
}
variable "associate_public_ip_address" {
  description = "true or false for assign public IP for jenkins"
}
variable "access_key_file" {
  description = "full path to key"
}
variable "bastion_access_key" {
  description = "bastion key"
}
variable "bastion_public_ip" {
  description = "Public Ip of Bastion host for perform action"

}
