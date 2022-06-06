/*
  Galit Udovik

  OpsSchool DevOps cource
  File with declaration of variables for web servers
*/

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
variable "route53_host_zone_name" {
  description = "Name of hosted zone"
}
variable "route53_record_name" {
  description = "Name of record which will be belongs to specific address"
}
variable "route53_address_list_array" {
  description = "List of addresses for associate to specific route record name"
  type        = list(string)
}
variable "ttl" {
  description = "TTL value"
  default     = 300
}
