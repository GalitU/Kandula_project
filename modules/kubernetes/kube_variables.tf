/*
  Galit Udovik

  OpsSchool DevOps cource
  File with declaration of variables for web servers
*/

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
variable "cluster_name" {
  description = "Name of cluster"
}
variable "kubernetes_version" {
  default     = 1.21
  description = "kubernetes version"
}
variable "kube_node_sec_groups" {
  description = "Security groups"
  type        = list(string)
}
variable "kube_pvt_subnets_ids" {
  description = "Private subnets"
  type        = list(string)
}
variable "kube_pub_subnets_ids" {
  description = "Public subnets"
  type        = list(string)
}
locals {
  k8s_service_account_namespace = "default"
  k8s_service_account_name      = "kandula-mid-account-name"
}
