/*
  Galit Udovik

  OpsSchool DevOps cource
  File with declaration of variables for web servers
*/
variable "cluster_name" {
  description = "Cluster name"
}
variable "aws_access_key_id" {
  description = "AWS_ACCESS_KEY_ID in base64"
}
variable "aws_sercret_access_key" {
  description = "AWS_SECRET_ACCESS_KEY in base64"
}
variable "aws_default_region" {
  description = "AWS_DEFAULT_REGION in base64"
}
variable "login_user_name" {
  description = "USER_NAME in base64"
}
variable "login_password" {
  description = "USER_PASSWORD in base64"
}
variable "termination_dry_run" {
  description = "TERMINATION_DRY_RUN in base64"
}
variable "kandula_image_version" {
  description = "Image version"
}
variable "route53_host_zone_name" {
  description = "Route 53 host zone name"
}
