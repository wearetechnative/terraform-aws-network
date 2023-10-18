resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name}-igw"
  }
}

resource "aws_route" "internet_gateway" {
  for_each = { for key, value in aws_subnet.this : key => value if var.configuration.subnet_groups[var.configuration.subnets[key].subnet_group].internet_gateway && !var.configuration.subnet_groups[var.configuration.subnets[key].subnet_group].nat_gateway }

  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}
