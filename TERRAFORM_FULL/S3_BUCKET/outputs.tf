/*
  Galit Udovik

  OpsSchool DevOps cource
  Output data
*/

output "s3_bucket_name" {
  value = module.gu_s3_bucket.s3_bucket_name
}

output "s3_name_arn" {
  value = module.gu_s3_bucket.s3_name_arn
}
