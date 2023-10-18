resource "aws_vpc_dhcp_options" "default" {
  domain_name_servers = ["AmazonProvidedDNS"]

  # https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html
  # Section: Rules and considerations
  domain_name = data.aws_region.current.name != "us-east-1" ? "${data.aws_region.current.name}.compute.internal" : "ec2.internal"

  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-time.html
  ntp_servers = ["169.254.169.123"]

  tags = {
    Name = local.name
    Type = "default"
  }
}
