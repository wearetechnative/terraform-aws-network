module "subnet_addrs" {
  source                   = "hashicorp/subnets/cidr"
  terraform_module_version = "~>1.0"

  base_cidr_block = aws_vpc.this.cidr_block
  # minimal of 4 free bits is required otherwise AWS will not accept the subnet
  networks = [for key, value in var.configuration.subnets : { "name" : key, "new_bits" : (32 - local.base_address_netmask) - max(value.networkaddress_bits, 4) }]
}

resource "aws_subnet" "this" {
  for_each = { for key, value in var.configuration.subnets : key => value if value.is_provisioned }

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.availability_zone
  cidr_block        = module.subnet_addrs.network_cidr_blocks[each.key]

  tags = {
    Name = each.value.name
  }
}

resource "aws_network_acl" "this" {
  for_each = aws_subnet.this

  vpc_id = aws_vpc.this.id
}

resource "aws_network_acl_rule" "allow_all_inbound" {
  for_each = aws_network_acl.this

  network_acl_id = each.value.id
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "allow_all_outbound" {
  for_each = aws_network_acl.this

  network_acl_id = each.value.id
  rule_number    = 100
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_association" "this" {
  for_each = aws_subnet.this

  network_acl_id = aws_network_acl.this[each.key].id
  subnet_id      = each.value.id
}
