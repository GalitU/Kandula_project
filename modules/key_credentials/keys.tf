locals {
  pem_key_name     = "Key_${var.key_purpose}_${var.application_task}_${var.application_name}"
  pem_key_filename = "${local.pem_key_name}.pem"
  pem_key_abs_path = "${var.root_directory}"
}

resource "tls_private_key" "pvt_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "pvt_key" {
  key_name   = local.pem_key_name
  public_key = tls_private_key.pvt_key.public_key_openssh
  tags = {
    Name      = local.pem_key_name
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "local_sensitive_file" "private_key_file" {
  content  = tls_private_key.pvt_key.private_key_pem
  filename = local.pem_key_filename
}

resource "null_resource" "chmod_400_key" {
  provisioner "local-exec" {
    command = "chmod 400 ${local.pem_key_abs_path}/${local_sensitive_file.private_key_file.filename}"
  }
}

output "private_key_file_fingerprint" {
  value = aws_key_pair.pvt_key.fingerprint
}

output "private_key_file_name" {
  value = aws_key_pair.pvt_key.key_name
}

output "private_key_file_id" {
  value = aws_key_pair.pvt_key.id
}

output "private_key_file_with_path" {
  value = "${local.pem_key_abs_path}/${local_sensitive_file.private_key_file.filename}"
}

output "private_key_name_arn" {
  value = aws_key_pair.pvt_key.arn
}
output "private_key_name" {
  value = local.pem_key_name
}
output "public_key" {
  value = aws_key_pair.pvt_key.public_key
}
