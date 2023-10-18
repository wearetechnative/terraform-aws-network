locals {
  base_address_netmask = 16
  base_address         = "10.${var.vpc_cidr_partition_id}.0.0/${local.base_address_netmask}"

  # can be changed to variable in case we need multiple VPCs per account
  name = var.name

  # unique & used availability_zones
  # use sorting to keep array stable
  availability_zones_with_nat = sort(distinct([for key, value in var.configuration.subnets : value.availability_zone if value.is_provisioned && var.configuration.subnet_groups[value.subnet_group].nat_gateway]))
  route_nat_gateway_tag_name  = "NATGatewayRoutes"
}
