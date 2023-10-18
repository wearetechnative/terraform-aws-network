resource "aws_vpc" "this" {
  cidr_block = local.base_address

  # a lot of services require the below and no known conflicts exist
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = local.name
  }
}
