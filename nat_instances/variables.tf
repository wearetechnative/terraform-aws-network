variable "name" {
  description = "NAT Instance ASG name."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key to use for EBS encryption."
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID to locate NAT gateway in."
  type        = string
}

variable "sqs_dlq_arn" {
  description = "SQS DLQ Arn to transfer unprocessed / failed infra messages into."
  type        = string
}

variable "route_nat_gateway_tag_name" {
  description = "Subnet NAT gateway tag to detect subnets which require NAT routes."
  type        = string
}

variable "nat_route_table_arns" {
  description = "List of NAT route tables that need to be updated by the Lambda."
  type        = list(string)
}
