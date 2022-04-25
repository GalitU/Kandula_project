variable "application_task" {
  description = "Name of envinronment"
}
variable "created_by" {
  description = "Create manually or by terraform"
}
variable "application_owner" {
  description = "Owner name"
  default     = "Galit Udovik"
}
variable "application_name" {
  description = "Application name"
}
variable "ec2_role" {
  description = "EC2 role info"
}
variable "ec2_role_assign_for" {
  description = "EC2 role info will be assigned to"
}
