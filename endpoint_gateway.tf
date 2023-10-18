# all free so no harm but only benefit of adding them

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [ for k, v in aws_route_table.this : v.id ]
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       =  aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [ for k, v in aws_route_table.this : v.id ]
}
