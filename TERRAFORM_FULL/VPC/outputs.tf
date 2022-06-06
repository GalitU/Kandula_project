/*
  Galit Udovik

  OpsSchool DevOps cource
  Output data
*/

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}
output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}
output "data_aws_region" {
  value = data.aws_region.current.name
}
output "data_aws_region_description" {
  value = data.aws_region.current.description
}

/* VPC info */
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "vpc_pub-subnet" {
  value = join(",\n", module.vpc.pub_subnets[*].cidr_block)
}
output "vpc_pvt-subnet" {
  value = join(",\n", module.vpc.pvt_subnets[*].cidr_block)
}
