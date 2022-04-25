
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
variable "role_policy_type" {
  description = "Role Policy type"
}

variable "access_policy_description" {
  description = "Policy decription"
}

variable "access_policy_type" {
  description = "Policy type"
}
