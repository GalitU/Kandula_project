/*
  Galit Udovik

  OpsSchool DevOps cource
  File with declaration of variables for web servers
*/
variable "subnets" {
  description = "Subnet for instances"
  type        = list(string)
}
variable "lb_sec_group_array" {
  type        = list(string)
  description = "Security groups for regular servers of LB only"
}

variable "vpc_id" {
  description = "Vpc id"
}
variable "application_name" {
  description = "Application name"
}
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
variable "servers_for_attach_to_lb" {
  description = "List of instances for attach to lb"
  type        = list(string)
}
variable "aws_acm_certificate_id" {
  description = "ARN of allowed certificate to public domain"
}
variable "listener_ports" {
  description = "List of ports for lb listeners"
  type        = list(number)
}
variable "target_port" {
  description = "Port for lb represent"
}
variable "idle_timeout" {
  description = "Idle timeout of healt checker"
  default     = 60
}
variable "internal" {
  description = "Expose tyle"
}
variable "listener_protocols" {
  description = "List of protocols of forwarding for"
  type        = list(string)
}
variable "lb_purpose" {
  description = "Target of lb, for example web_server"
}
