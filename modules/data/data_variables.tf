
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
variable "vpc_name" {
  description = "Name of VPC for get its info"
}
variable "route53_host_zone_name" {
  description = "Name of hosted zone where we will add records"
}
