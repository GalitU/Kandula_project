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
variable "ec2_instance_type" {
  description = "Type of instance machine"
  default     = "t3.micro"
}
variable "ami" {
  description = "Image type of instance"
  default     = "ami-0d527b8c289b4af7f"
}
variable "count_instances" {
  description = "Count of Web server/ DB  instances"
}
variable "subnet_association_tag" {
  description = "For filter relevant subnets"
}
/*variable "ec2_subnets" {
  description = "Subnet for ec2 instances"
  type        = list(string)
}
*/
variable "ec2_sec_group_array" {
  description = "List of relevant security groups for web instances"
  type        = list(string)
}
variable "type_of_subnet" {
  description = "Public or Private for type of subnet"
}
/*variable "lb_sec_group_array" {
  description = "Security groups for LB only"
  type        = list(string)
}*/

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
variable "ec2_purpose" {
  description = "ec2 purpose"
  type        = string
}
variable "ec2_OS" {
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
  description = "Role info profiler for EC2 instance"
}
variable "user_data_file" {
  description = "File for start the server"
}
variable "associate_public_ip_address" {
  description = "true or false for assign public IP for ec2"
}
