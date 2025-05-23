module "ec2_asg" {
  source = "github.com/wearetechnative/terraform-aws-ec2-asg?ref=d654386d6baf67ff00d6e525448b9f2b3a48df3e"

  # configured with ARM image and arch to save cost
  initial_amount_of_pods = 1

  name                   = var.name

  ec2_ami_name_filter_list = ["amzn2-ami-ecs-hvm-2.0.*-arm64-ebs"]
  ec2_ami_owner_list       = ["591542846629"] # Amazon
  ec2_root_initial_size    = 30
  ec2_instance_type        = "t4g.nano"

  instance_role_name = module.instance_role.role_name
  security_group_ids = [aws_security_group.this.id]
  user_data = templatefile("${path.module}/userdata.tftpl", {
    cloudwatch_config_ssm_parameter_name = aws_ssm_parameter.cloudwatchagent_config.name
  })

  subnet_ids                = [var.public_subnet_id]
  use_public_ip             = false # we are the NAT gateway
  use_floating_ip           = true
  user_data_completion_hook = true
  sqs_dlq_arn               = var.sqs_dlq_arn
  kms_key_arn               = var.kms_key_arn

  lifecycle_hooks = local.lifecycle_hooks
}

data "aws_subnet" "subnet_for_vpc" {
  id = var.public_subnet_id
}

data "aws_vpc" "this" {
  id = data.aws_subnet.subnet_for_vpc.vpc_id
}

resource "aws_security_group" "this" {
  description = "Security group for ${var.name} NAT instances."
  vpc_id      = data.aws_subnet.subnet_for_vpc.vpc_id
}

resource "aws_security_group_rule" "allow_from_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "allow_wan_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

module "instance_role" {
  source = "github.com/wearetechnative/terraform-aws-iam-role?ref=9229bbd0280807cbc49f194ff6d2741265dc108a"

  role_name = "nat-${var.name}-instance-role"
  role_path = "/network/"

  aws_managed_policies = ["AmazonSSMManagedInstanceCore"]
  customer_managed_policies = {
    "cloudwatch_logs" : jsondecode(data.aws_iam_policy_document.cloudwatch_logs.json)
    "cloudwatch_agent" : jsondecode(data.aws_iam_policy_document.cloudwatch_agent.json)
  }

  trust_relationship = {
    "ec2" : { "identifier" : "ec2.amazonaws.com", "identifier_type" : "Service", "enforce_mfa" : false, "enforce_userprincipal" : false, "external_id" : null, "prevent_account_confuseddeputy" : false }
  }
}
