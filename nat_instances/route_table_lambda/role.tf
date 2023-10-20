module "iam_role" {

  source = "git@github.com:wearetechnative/terraform-aws-iam-role"

  role_name = var.name
  role_path = "/ecs-dns-lambda/"

  aws_managed_policies = []
  customer_managed_policies = {
    "sqs_dlq" : jsondecode(data.aws_iam_policy_document.sqs_dlq.json)
    "lifecycle" : jsondecode(data.aws_iam_policy_document.lifecycle.json)
    "DetectAndUpdateRouteTables" : jsondecode(data.aws_iam_policy_document.detectandupdateroutetables.json)
  }

  trust_relationship = {
    "ec2" : { "identifier" : "lambda.amazonaws.com", "identifier_type" : "Service", "enforce_mfa" : false, "enforce_userprincipal" : false, "external_id" : null, "prevent_account_confuseddeputy" : false }
    "technative" : { "identifier" : "521402697040", "identifier_type" : "AWS", "enforce_mfa" : false, "enforce_userprincipal" : false, "external_id" : null, "prevent_account_confuseddeputy" : false }
  }
}

data "aws_iam_policy_document" "sqs_dlq" {
  statement {
    sid = "AllowDLQAccess"

    actions = ["sqs:SendMessage"]

    resources = [var.sqs_dlq_arn]
  }
}

data "aws_iam_policy_document" "lifecycle" {
  statement {
    sid = "AllowLifeCycleActionForEIPLambda3"

    actions = ["autoscaling:CompleteLifecycleAction"]

    resources = [var.autoscalinggroup_arn]
  }
}

data "aws_iam_policy_document" "detectandupdateroutetables" {
  statement {
    sid = "DetectRouteTables"

    actions = ["autoscaling:DescribeAutoScalingGroups"
      , "ec2:DescribeSubnets"
      , "ec2:DescribeRouteTables"
    ]

    resources = ["*"]
  }

  statement {
    sid = "UpdateRouteTables"

    actions = ["ec2:DeleteRoute", "ec2:CreateRoute"]

    resources = var.nat_route_table_arns
  }

  statement {
    sid = "UpdateInstance"

    actions = ["ec2:ModifyInstanceAttribute"]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/aws:autoscaling:groupName"
      values   = [var.autoscalinggroup_name]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Attribute"
      values   = ["SourceDestCheck"]
    }
  }
}
