/*
  Galit Udovik

  OpsSchool DevOps cource
  File with declaration of variables
*/
variable "region" {
  description = "Region where the infrastructure will be created"
  default     = "eu-central-1"
}
variable "vpc_name" {
    description = "Name of VPC for get its info"
    default = "VPC-mprj-Kandula"
}
variable "application_name" {
  description = "Application name, HW, mid_prj"
  default     = "MPrj"
}
variable "application_task" {
  description = "Name of task"
  default     = "Kandula"
}
variable "application_owner" {
  description = "Owner name"
  default     = "Galit Udovik"
}
variable "created_by" {
  description = "Is it was created manually or by terraform"
  default     = "terraform"
}
