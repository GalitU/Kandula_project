/*
  Galit Udovik

  OpsSchool DevOps cource
  Configure Ealstic IP addresses
*/

resource "aws_eip" "eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  count      = length(local.az)
  tags = {
    Name      = "EIP_IGW-${count.index + 1}-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}
