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

/* Keys */
output "private_key_files_with_path" {
  value = join(",\n",
    [
      module.key_credentials_consul.private_key_file_with_path,
      module.key_credentials_bastion.private_key_file_with_path,
      module.key_credentials_master.private_key_file_with_path,
      module.key_credentials_webserver.private_key_file_with_path
  ])
}
output "private_key_names" {
  value = join(",\n",
    [
      module.key_credentials_consul.private_key_name,
      module.key_credentials_bastion.private_key_name,
      module.key_credentials_master.private_key_name,
      module.key_credentials_webserver.private_key_name
  ])
}
