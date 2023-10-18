resource "aws_cloudwatch_event_rule" "lambda" {
  name        = var.name
  description = "Sends ASG lifecycle hook route table updates to Lambda for create and delete."

  event_bus_name = "default"
  event_pattern = jsonencode({
    "source" : ["aws.autoscaling"]
    "resources" : [var.autoscalinggroup_arn]
    "detail" : {
      "LifecycleHookName" : var.lifecycle_hook_names
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule           = aws_cloudwatch_event_rule.lambda.name
  event_bus_name = aws_cloudwatch_event_rule.lambda.event_bus_name

  arn = module.lambda.lambda_function_arn

  dead_letter_config {
    arn = var.sqs_dlq_arn
  }

  retry_policy {
    maximum_event_age_in_seconds = 60
    maximum_retry_attempts       = 3
  }
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id_prefix = var.name
  action              = "lambda:InvokeFunction"
  function_name       = substr(data.aws_arn.lambda.resource, length("function:"), length(data.aws_arn.lambda.resource) - length("function:"))
  principal           = "events.amazonaws.com"
  source_arn          = aws_cloudwatch_event_rule.lambda.arn
}
