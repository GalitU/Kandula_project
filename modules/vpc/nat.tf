/*
  Galit Udovik

  OpsSchool DevOps cource
  Configure NAT component
*/

resource "aws_nat_gateway" "nat" {
  count         = length(local.az)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.pub_subnet[count.index].id

  tags = {
    Name      = "NAT-${count.index + 1}-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}
