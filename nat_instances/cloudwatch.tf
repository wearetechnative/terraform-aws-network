data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    sid = "CloudWatchLogGroups"

    actions = ["logs:PutLogEvents", "logs:CreateLogStream"]

    resources = ["${aws_cloudwatch_log_group.nat_instance.arn}:log-stream:*"]
  }
}

data "aws_iam_policy_document" "cloudwatch_agent" {
  statement {
    sid = "CloudWatchConfigParameters"

    actions = ["ssm:GetParameter"]

    resources = [aws_ssm_parameter.cloudwatchagent_config.arn]
  }
}

resource "aws_cloudwatch_log_group" "nat_instance" {
  name = "/nat_instance/${var.name}"

  retention_in_days = 90
  kms_key_id        = var.kms_key_arn
}

resource "aws_ssm_parameter" "cloudwatchagent_config" {
  name  = "/ec2_asg/natinstance/${var.name}/cloudwatch-config"
  type  = "String"
  value = <<EOF
{
	"agent": {
		"metrics_collection_interval": 60,
		"run_as_user": "root"
	},
	"logs": {
		"logs_collected": {
			"files": {
				"collect_list": [{
					"file_path": "/var/log/messages",
					"log_group_name": "${aws_cloudwatch_log_group.nat_instance.name}",
					"log_stream_name": "{instance_id}/messages"
		        },{
					"file_path": "/var/log/cloud-init-output.log",
					"log_group_name": "${aws_cloudwatch_log_group.nat_instance.name}",
					"log_stream_name": "{instance_id}/cloud-init-output"
				},{
					"file_path": "/var/log/ecs/ecs-agent.log",
					"log_group_name": "${aws_cloudwatch_log_group.nat_instance.name}",
					"log_stream_name": "{instance_id}/ecs"
				}]
			}
		}
	}
}
EOF
}
