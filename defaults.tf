resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.this.default_network_acl_id

  tags = {
    Name = local.name
    Type = "default"
  }
}

# clear, so in case of misconfiguration we get no traffic
# also sets any tags so these resources are managed by TerraForm
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  route = []

  tags = {
    Name = local.name
    Type = "default"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.name
    Type = "default"
  }
}

resource "aws_vpc_dhcp_options_association" "default" {
  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.default.id
}
