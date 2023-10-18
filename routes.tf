resource "aws_route_table" "this" {
  for_each = aws_subnet.this

  vpc_id = aws_vpc.this.id

  tags = {
    Name                                  = var.configuration.subnets[each.key].name
    "${local.route_nat_gateway_tag_name}" = var.configuration.subnet_groups[var.configuration.subnets[each.key].subnet_group].nat_gateway
  }
}

resource "aws_route_table_association" "this" {
  for_each = aws_subnet.this

  subnet_id      = each.value.id
  route_table_id = aws_route_table.this[each.key].id
}
