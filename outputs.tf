output "subnet_groups" {
  value = { for group_key, group_value in var.configuration.subnet_groups :
    group_key => merge(merge({ "route_table_ids" : [for key, value in aws_route_table.this : value.id if var.configuration.subnets[key].subnet_group == group_key] }
      , { "network_acl_ids" : [for key, value in aws_network_acl.this : value.id if var.configuration.subnets[key].subnet_group == group_key] })
      , { "subnets" : { for subnet_key, subnet_value in var.configuration.subnets : subnet_value.name => { "subnet_id" : aws_subnet.this[subnet_key].id }
    if subnet_value.subnet_group == group_key && lookup(aws_subnet.this, subnet_key, 0) != 0 } })
  }
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "cidr_blocks" {
  value = aws_vpc.this.cidr_block
}

output "subnet_ids_by_group" {
  value = {
    for group_key in keys(var.configuration.subnet_groups) :
    group_key => [
      for subnet_key, subnet in aws_subnet.this :
      subnet.id
      if var.configuration.subnets[subnet_key].subnet_group == group_key
    ]
  }
}

output "route_table_ids_by_group" {
  value = {
    for group_key in keys(var.configuration.subnet_groups) :
    group_key => [
      for subnet_key, route_table in aws_route_table.this :
      route_table.id
      if var.configuration.subnets[subnet_key].subnet_group == group_key
    ]
  }
}
