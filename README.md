# Terraform AWS [Network] ![](https://img.shields.io/github/workflow/status/wearetechnative/terraform-aws-network/tflint.yaml?style=plastic)

TechNative's VPC boilerplate module.

[![](we-are-technative.png)](https://www.technative.nl)

## Design goals

- Standard 'Module guidelines' from https://docs-mcs.technative.eu/infra-as-code/terraform-code-organization/.
- Any network specific design goals are listed below.
- Do not implement security controls. Security is handled in the security groups.
- Reset and control any default resources as much as possible.

## Features

- create VPC
- advanced subnet configuration in JSON
- cheap NAT's (see `input_use_nat_instances`)

## Usage

Use the network.example.json to create your own network. Any users must use the
outputs subnet_groups and be configured to use an entire subnet_group. Any
additions on the network will then be automatically propagated to its users
(e.g. ASG, ALB).

This module defines subnet_groups as collection of subnets that can easily be
extended and must be used as an single entity. Each user of subnets must have
its subnet_group key configured and fetch any corresponding subnets from the
output.subnet_groups. This allows any additionally subnets to be automatically
picked up by the users.

Beware: The subnets map key must be added in ascending order and removing any
existing subnet must happen by setting is_provisioned to false. The reasoning
for this is that we use hashicorp/subnets/cidr which calculates the CIDR blocks
for us. These CIDR blocks don't have gaps and are consecutive. Only when the
subnets map is extended then this mapping will remain stable.

Any subnet.subnet_group must refer to an existing key in the subnet_groups map.
Use networkaddress_bits to define the amount of addresses provisioned for the
subnet. This number must be higher than 3.

networkaddress_bits = 4 -> 12 available addresses
networkaddress_bits = 8 -> 251 available addresses

## Future work / ideas

Possibility of automatically adding subnet groups when new availability zones
arrive. A downside to this is the fact that if many new azs are added then we
overflow the available CIDR block. So it's not included for now. Each subnet
still requires some manual configuration.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.22.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_nat_instances"></a> [nat\_instances](#module\_nat\_instances) | ./nat_instances | n/a |
| <a name="module_s3_flow_logs"></a> [s3\_flow\_logs](#module\_s3\_flow\_logs) | git@github.com:wearetechnative/terraform-aws-s3 | 73aa13eeb59184ce88cd9e925e9dc1504cc18940 |
| <a name="module_subnet_addrs"></a> [subnet\_addrs](#module\_subnet\_addrs) | hashicorp/subnets/cidr | 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_default_network_acl.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association) | resource |
| [aws_network_acl_rule.allow_all_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.allow_all_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_route.internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_dhcp_options.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |
| [aws_vpc_endpoint.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_configuration"></a> [configuration](#input\_configuration) | Configuration object indicating required setup. | <pre>object({<br>    subnet_groups : map(object({<br>      nat_gateway : bool<br>      internet_gateway : bool<br>    }))<br>    subnets : map(object({<br>      name : string<br>      is_provisioned : bool<br>      availability_zone : string<br>      networkaddress_bits : number<br>      subnet_group : string<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key to use for VPC Flow logs. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | VPC name | `string` | n/a | yes |
| <a name="input_sqs_dlq_arn"></a> [sqs\_dlq\_arn](#input\_sqs\_dlq\_arn) | SQS DLQ Arn to transfer unprocessed / failed infra messages into. | `string` | n/a | yes |
| <a name="input_use_nat_instances"></a> [use\_nat\_instances](#input\_use\_nat\_instances) | Use cheap (t4g.nano) instances to save cost. | `bool` | `false` | no |
| <a name="input_vpc_cidr_partition_id"></a> [vpc\_cidr\_partition\_id](#input\_vpc\_cidr\_partition\_id) | A number between 0 and 255 to prevent overlapping CIDR ranges. | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_groups"></a> [subnet\_groups](#output\_subnet\_groups) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END_TF_DOCS -->
