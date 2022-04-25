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
variable "root_directory" {
  description = "Root directory from which was called"
}
/*
variable "key_name" {
  description = "Private key name of ssh key to attach to hosts genereted during apply, opsschool_consul_key for example"
}
*/
