# stolen from https://github.com/hashicorp/terraform/issues/8344

module "lambda" {
  source = "git@github.com:wearetechnative/terraform-aws-lambda?ref=6d454d4a19f565c1ef423f870b28cadf6e4800d6"

  name              = var.name
  role_arn          = module.iam_role.role_arn
  role_arn_provided = true

  environment_variables = {
    "ROUTE_NAT_GATEWAY_TAG_NAME" = var.route_nat_gateway_tag_name
  }

  handler                   = "lambda_function.lambda_handler"
  source_type               = "local"
  source_directory_location = "${path.module}/source"
  source_file_name          = null
  sqs_dlq_arn               = var.sqs_dlq_arn

  kms_key_arn = var.kms_key_arn
  memory_size = 128
  timeout     = 10
  runtime     = "python3.9"
}

data "aws_arn" "lambda" {
  arn = module.lambda.lambda_function_arn
}

resource "aws_lambda_function_event_invoke_config" "dlq" {
  function_name = var.name

  # NOTE This is disabled as this caused continuous configuration drift (60>0>null) in aws-proviver 5.26
  # maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 2

  destination_config {
    on_failure {
      destination = var.sqs_dlq_arn
    }
  }

  depends_on = [
    module.lambda
  ]
}
