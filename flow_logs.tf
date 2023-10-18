resource "aws_flow_log" "this" {
  traffic_type         = "ALL"
  log_destination      = module.s3_flow_logs.s3_arn
  log_destination_type = "s3"
  vpc_id               = aws_vpc.this.id

  destination_options {
    file_format                = "parquet"
    hive_compatible_partitions = true
    per_hour_partition         = true
  }

  tags = {
    "Name" = var.name
  }
}

module "s3_flow_logs" {
  source = "git@github.com:TechNative-B-V/terraform-aws-module-s3?ref=480790b2f1190bc1c4f94d2346e18ffcfa112c4f"

  name                   = "vpc-flow-logs-${replace(var.name, "_", "-")}"
  kms_key_arn            = var.kms_key_arn
  bucket_policy_addition = jsondecode(data.aws_iam_policy_document.vpc_flow_logs.json)
}

data "aws_iam_policy_document" "vpc_flow_logs" {
  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = ["<bucket>/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = ["<bucket>"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }

  statement {
    # s3:ListBucket is not listed in docs, but CloudTrail study indicates that HeadBucket is being performed which requires this
    sid = "AWSLogDeliveryHeadBucket"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:ListBucket"]

    resources = ["<bucket>"]

    # still fails if included so therefore excluding
    # condition {
    #   test = "StringEquals"
    #   variable = "aws:SourceAccount"
    #   values = [data.aws_caller_identity.current.account_id]
    # }

    # condition {
    #   test = "ArnLike"
    #   variable = "aws:SourceArn"
    #   values = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    # }
  }
}
