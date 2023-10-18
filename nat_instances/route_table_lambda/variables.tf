variable "name" {
  description = "Unique name for EC2 with ASG setup."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key for encrypting CloudWatch Logs. More uses might be added later."
  type        = string
}

variable "sqs_dlq_arn" {
  description = "Required normal SQS queue to be used as DLQ for EventBridge."
  type        = string
}

variable "autoscalinggroup_arn" {
  description = "ASG ARN for policy."
  type        = string
}

variable "autoscalinggroup_name" {
  description = "ASG name for policy."
  type        = string
}

variable "lifecycle_hook_names" {
  description = "Hook name for the Lambda to trigger on."
  type        = list(string)
}

variable "route_nat_gateway_tag_name" {
  description = "Subnet NAT gateway tag to detect subnets which require NAT routes."
  type        = string
}

variable "nat_route_table_arns" {
  description = "List of NAT route tables that need to be updated by the Lambda."
  type        = list(string)
}
