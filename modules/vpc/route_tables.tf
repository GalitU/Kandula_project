/*
  Galit Udovik

  OpsSchool DevOps cource
  Configure Route tables
*/

/* Public route table and association */
resource "aws_route_table" "pub_route_tbl" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "PUB_RT-${lower(var.application_name)}-${var.application_task}"
    App_name  = var.application_name
    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_route" "pub_route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.pub_route_tbl.id
}

resource "aws_route_table_association" "pub_route_ass" {
  count          = length(aws_subnet.pub_subnet)
  subnet_id      = aws_subnet.pub_subnet[count.index % length(local.az)].id
  route_table_id = aws_route_table.pub_route_tbl.id
}

/*-----------------------*/
/* Private route table and association */
resource "aws_route_table" "pvt_route_tbl" {
  vpc_id = aws_vpc.vpc.id
  count  = length(local.az)

  tags = {
    Name = "PVT_RT-${count.index + 1}-${lower(var.application_name)}-${var.application_task}"

    Task      = var.application_task
    Owner     = var.application_owner
    CreatedBy = var.created_by
  }
}

resource "aws_route" "pvt_route" {
  count                  = length(local.az)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat[count.index].id
  route_table_id         = aws_route_table.pvt_route_tbl[count.index].id
}

resource "aws_route_table_association" "pvt_route_ass" {
  count          = length(aws_subnet.pvt_subnet)
  subnet_id      = aws_subnet.pvt_subnet[count.index].id
  route_table_id = aws_route_table.pvt_route_tbl[count.index % length(local.az)].id
}
