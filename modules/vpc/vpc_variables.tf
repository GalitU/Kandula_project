/*
  Galit Udovik

  OpsSchool DevOps cource
  File with declaration of variables for web servers
*/

variable "region" {
  description = "Region where the infrastructure will be created"
}
variable "application_name" {
  description = "Application name"
}
variable "application_task" {
  description = "Name of envinronment"
}
variable "application_owner" {
  description = "Owner name"
  default     = "Galit Udovik"
}
variable "created_by" {
  description = "Create manually or by terraform"
}
variable "cidr_block_pub" {
  description = "CIDR block of public subnet"
  type        = list(string)
}
variable "cidr_block_pvt" {
  description = "CIDR block of private subnet"
  type        = list(string)
}
variable "special_cidr_block" {
  description = "Special CIDR block for ingress and egress for SSH"
  type        = list(string)
}
variable "subnet_pvt_prefix_template_arr" {
  description = "Prefix for pvt subnets"
}
variable "subnet_pub_prefix_template_arr" {
  description = "Prefix for pvt subnets"
}
