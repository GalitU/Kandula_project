/*
  Galit Udovik

  OpsSchool DevOps cource
  File with declaration of variables
*/
variable "region" {
  description = "Region where the infrastructure will be created"
  default     = "eu-central-1"
}
variable "ec2_instance_type" {
  description = "Type of web instance machine"
  default     = "t2.micro"
}
variable "db_instance_type" {
  description = "Type of db instance machine"
  default     = "t2.micro"
}
variable "ami" {
  description = "Image type of instance"
  default     = "ami-01ec9ccdf0676a480" # AMI UBUNTU 21.04
}
variable "count_instances" {
  description = "Count of Web server/ DB  instances"
  default     = 2
}
variable "ec2_OS" {
  description = "OS of Operating system"
  default     = "Ubuntu"
}
variable "application_name" {
  description = "Application name, HW, mid_prj"
  default     = "K8S"
}
variable "application_task" {
  description = "Name of task"
  default     = "Alone"
}
variable "application_owner" {
  description = "Owner name"
  default     = "Galit Udovik"
}
variable "created_by" {
  description = "Is it was created manually or by terraform"
  default     = "terraform"
}
variable "cidr_block_pub" {
  description = "CIDR block of public subnet"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "cidr_block_pvt" {
  description = "CIDR block of private subnet"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}
