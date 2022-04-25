/*
  Galit Udovik

  OpsSchool DevOps cource
  IAM role file
*/

/*
resource "aws_iam_role" "web_server_role" {
  name = "web_server_role-${lower(var.application_name)}-${var.application_task}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name  = "web_server_role-${lower(var.application_name)}-${var.application_task}"
    Task  = var.application_task
    Owner = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_iam_instance_profile" "web_server_role" {
  name = "web_server_role-${lower(var.application_name)}-${var.application_task}"
  role = aws_iam_role.web_server_role.name

  tags = {
    Name  = "web_server_role-${lower(var.application_name)}-${var.application_task}"
    Task  = var.application_task
    Owner = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_iam_policy" "s3_bucket_policy" {
  name        = "s3_bucket_policy-${lower(var.application_name)}-${var.application_task}"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Stmt1546506260896",
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : "arn:aws:s3:::s3-${lower(var.application_name)}-${var.application_task}-bucket/*"
      }
    ]
  })
  tags = {
    Name  = "s3_bucket_policy-${lower(var.application_name)}-${var.application_task}"
    Task  = var.application_task
    Owner = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_iam_role_policy" "web_server_role_policy" {
  name   = "web_server_role_policy-${lower(var.application_name)}-${var.application_task}"
  role   = aws_iam_role.web_server_role.name
  policy = aws_iam_policy.s3_bucket_policy.policy
}


*/
