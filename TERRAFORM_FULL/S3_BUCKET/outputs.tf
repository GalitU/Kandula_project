/*
  Galit Udovik

  OpsSchool DevOps cource
  Output data
*/

output "s3_bucket_name" {
  value = module.s3_bucket.s3_bucket_name
}

output "s3_name_arn" {
  value = module.s3_bucket.s3_name_arn
}
