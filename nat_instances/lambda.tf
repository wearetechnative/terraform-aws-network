module "route_table_lambda" {
  source = "./route_table_lambda/"

  name        = var.name
  kms_key_arn = var.kms_key_arn
  sqs_dlq_arn = var.sqs_dlq_arn

  lifecycle_hook_names       = [for k, v in local.lifecycle_hooks : k]
  autoscalinggroup_arn       = module.ec2_asg.autoscaling_group_arn
  autoscalinggroup_name      = module.ec2_asg.autoscaling_group_name
  route_nat_gateway_tag_name = var.route_nat_gateway_tag_name

  nat_route_table_arns = var.nat_route_table_arns
}
