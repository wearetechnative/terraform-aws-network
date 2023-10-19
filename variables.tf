variable "vpc_cidr_partition_id" {
  description = "A number between 0 and 255 to prevent overlapping CIDR ranges."
  type        = number
}

variable "name" {
  description = "VPC name"
  type        = string
}

variable "configuration" {
  description = "Configuration object indicating required setup."
  type = object({
    subnet_groups : map(object({
      nat_gateway : bool
      internet_gateway : bool
    }))
    subnets : map(object({
      name : string
      is_provisioned : bool
      availability_zone : string
      networkaddress_bits : number
      subnet_group : string
    }))
  })
}

variable "kms_key_arn" {
  description = "KMS key to use for VPC Flow logs."
  type        = string
}

variable "use_nat_instances" {
  description = "Use cheap (t4g.nano) instances to save cost."
  type        = bool
  default     = false
}

variable "sqs_dlq_arn" {
  description = "SQS DLQ Arn to transfer unprocessed / failed infra messages into."
  type        = string
}
