
resource "aws_iam_policy" "s3_bucket_policy" {
  name        = "${local.s3_bucket_name_lcl}_policy"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Stmt1546506260896",
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : "arn:aws:s3:::${local.s3_bucket_name_lcl}/*"
      }
    ]
  })
  tags = {
    Name      = "${local.s3_bucket_name_lcl}_policy"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_iam_role_policy" "ec2_server_role_policy" {
  name   = "${var.ec2_role_assign_for}_${local.s3_bucket_name_lcl}"
  role   = var.ec2_role
  policy = aws_iam_policy.s3_bucket_policy.policy
}
