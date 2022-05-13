locals {
  role_info = "${var.purpose}_${var.access_policy_description}_${var.application_task}_${var.application_name}"
}

# Create an IAM role for the auto-join
resource "aws_iam_role" "role_join" {
  name = "Role_${local.role_info}_join"
  assume_role_policy = var.role_policy_type

  tags = {
    Name      = "Role_Assume_${local.role_info}_join"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    Purpose   = var.purpose
    CreatedBy = var.created_by
  }
}

# Create the policy
resource "aws_iam_policy" "role_join" {
  name        = "Policy_${local.role_info}_join"
  description = "Allows Relevant nodes to describe instances for joining."
  policy = var.access_policy_type

  tags = {
    Name      = "Policy_${local.role_info}_join"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    Purpose   = var.purpose
    CreatedBy = var.created_by
  }
}

# Attach the policy
resource "aws_iam_policy_attachment" "role_join" {
  name       = "Policy_attach_${local.role_info}_join"
  roles      = [aws_iam_role.role_join.name]
  policy_arn = aws_iam_policy.role_join.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "role_join" {
  name = "Role_Instance_${local.role_info}_join1"
  role = aws_iam_role.role_join.name
}

output "role" {
  value = aws_iam_role.role_join.name
}
output "role_policy" {
  value = aws_iam_policy.role_join.name
}

output "iam_instance_profile" {
  value = aws_iam_instance_profile.role_join.name
}
output "iam_role_join_name" {
  value = aws_iam_role.role_join.name
}
