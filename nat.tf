resource "aws_eip" "this" {
  for_each = { for key in local.availability_zones_with_nat : key => key if !var.use_nat_instances }

  #vpc = true # dont support EC2-ClassicLink but otherwise TF keeps reacreating this resource
  domain = "vpc"

  # EIP may require IGW to exist prior to association. Use depends_on to set an explicit dependency on the IGW.
  depends_on = [
    aws_internet_gateway.this
  ]
}

resource "aws_nat_gateway" "this" {
  for_each = { for k, v in aws_eip.this : k => v if !var.use_nat_instances }

  connectivity_type = "public"
  allocation_id     = each.value.allocation_id
  # fetch first public subnet to locate nat gateway in the same az zone, if not available then crash
  subnet_id = element([for key, value in aws_subnet.this : value if value.availability_zone == each.key && !var.configuration.subnet_groups[var.configuration.subnets[key].subnet_group].nat_gateway && var.configuration.subnet_groups[var.configuration.subnets[key].subnet_group].internet_gateway], 0).id

  tags = {
    Name = join("-", [local.name, "nat", each.key])
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.this
  ]
}

module "nat_instances" {
  source = "./nat_instances"

  for_each = { for key in local.availability_zones_with_nat : key => key if var.use_nat_instances}

  name        = "nat-${var.name}-${each.key}"
  kms_key_arn = var.kms_key_arn
  # fetch first public subnet to locate nat gateway in in the same az zone, if not available then crash
  public_subnet_id           = element([for key, value in aws_subnet.this : value if value.availability_zone == each.key && !var.configuration.subnet_groups[var.configuration.subnets[key].subnet_group].nat_gateway && var.configuration.subnet_groups[var.configuration.subnets[key].subnet_group].internet_gateway], 0).id
  sqs_dlq_arn                = var.sqs_dlq_arn
  route_nat_gateway_tag_name = local.route_nat_gateway_tag_name

  nat_route_table_arns = [for k, v in aws_route_table.this : v.arn if v.tags[local.route_nat_gateway_tag_name] == "true"]

  depends_on = [
    aws_internet_gateway.this
  ]
}

resource "aws_route" "nat_gateway" {
  for_each = { for key, value in aws_subnet.this : key => value if !var.use_nat_instances && var.configuration.subnet_groups[var.configuration.subnets[key].subnet_group].nat_gateway }

  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.value.availability_zone].id
}
