/*
  Galit Udovik

  OpsSchool DevOps cource
  File with declaration of variables for web servers
*/
variable "subnets" {
  description = "Subnet for ec2 instances"
  type        = list(string)
}
variable "lb_consul_sec_group_array" {
  description = "Security groups for consul servers of LB only"
  type        = list(string)
}
variable "lb_ec2_sec_group_array" {
  description = "Security groups for regular servers of LB only"
  type        = list(string)
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
variable "consul_servers_for_attach_to_lb" {
  description = "List of consul instances for attach to lb"
  type        = list(string)
}
variable "ec2_servers_for_attach_to_lb" {
  description = "List of consul instances for attach to lb"
  type        = list(string)
}
variable "consul_listener_ports" {
  description = "List of ports for consul lb listeners"
  type        = list(number)
}
variable "ec2_listener_ports" {
  description = "List of ports for ec2 lb listeners"
  type        = list(number)
}
variable "consul_target_port" {
  description = "Port for consul lb represent ec2"
}

variable "ec2_target_port" {
  description = "Port for ec2 lb represent ec2"
}
variable "idle_timeout" {
  description = "Idle timeout of healt checker"
  default     = 60
}
variable "internal" {
  description = "Expose tyle"
}
variable "consul_listener_protocols" {
  description = "List of protocols of forwarding for consul"
  type        = list(string)
}
variable "ec2_listener_protocols" {
  description = "List of protocols of forwarding for ec2"
  type        = list(string)
}
variable "consul_lb_purpose" {
  description = "Target of lb, for example consul"
}
variable "ec2_lb_purpose" {
  description = "Target of lb, for example web_server"
}
