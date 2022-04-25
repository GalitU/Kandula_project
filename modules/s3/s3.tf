/*
  Galit Udovik
  OpsSchool DevOps cource
  S3 file
*/

locals {
  s3_bucket_name_lcl = "s3-${lower(var.application_name)}-${lower(var.application_task)}-bucket"
}
resource "aws_s3_bucket" "s3-backet-for-log" {
  bucket = local.s3_bucket_name_lcl

  tags = {
    Name      = local.s3_bucket_name_lcl
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.s3-backet-for-log.id
  acl    = "private"
}

output "s3_bucket_name" {
  value = local.s3_bucket_name_lcl
}

output "s3_name_arn" {
  value = aws_s3_bucket.s3-backet-for-log.arn
}
