import boto3
import json
import os
scaling = boto3.client('autoscaling')
ec2 = boto3.resource('ec2')
ec2_client = boto3.client('ec2')

def lambda_handler(event, context):
    print(event)
    eventDetail = event['detail']

    ec2_instance_id = event['detail']['EC2InstanceId']
    lifecycle_transition = event['detail']['LifecycleTransition']
    autoscaling_group_name = event['detail']['AutoScalingGroupName']
    autoscaling_group_arn = event['resources'][0]

    autoscaling_groups = scaling.describe_auto_scaling_groups(AutoScalingGroupNames=[autoscaling_group_name])['AutoScalingGroups']
    autoscaling_group = list(filter(lambda x: (x['AutoScalingGroupARN'] == autoscaling_group_arn), autoscaling_groups))[0]
    availability_zone = autoscaling_group['AvailabilityZones'][0]

    vpc_id = ec2.Subnet(autoscaling_group['VPCZoneIdentifier']).vpc_id
    route_nat_gateway_tag_name = os.environ['ROUTE_NAT_GATEWAY_TAG_NAME']

    def is_nat_route(route):
        gateway_tags = list(filter(lambda y: y['Key'] == route_nat_gateway_tag_name, route.tags))
        if len(gateway_tags) > 0:
            if gateway_tags[0]['Value'] == 'true':
                return True
            else:
                return False
        else:
            return False # default route

    nat_route_tables = list(filter(is_nat_route, ec2.Vpc(vpc_id).route_tables.all()))

    def is_nat_route_within_same_availability_zone(route):
        nat_route_tables_within_same_availability_zone = list(filter(lambda x: x.subnet.availability_zone == availability_zone, route.associations))
        return len(nat_route_tables_within_same_availability_zone) > 0

    nat_route_tables_within_same_availability_zone = list(filter(is_nat_route_within_same_availability_zone, nat_route_tables))

    for route_table in nat_route_tables_within_same_availability_zone:
        default_route_cidr = "0.0.0.0/0"
        default_routes = list(filter(lambda x: x.destination_cidr_block == default_route_cidr, route_table.routes))

        if len(default_routes) > 0:
            print(f'Deleting existing default route {default_route_cidr} from route table ${route_table.route_table_id}.')
            default_routes[0].delete()
        else:
            print(f'No default ${default_route_cidr} route found. Skipping deletion.')

        if lifecycle_transition == 'autoscaling:EC2_INSTANCE_LAUNCHING':
            print(f'Creating new default route in route table {route_table.route_table_id}.')

            route_table.create_route(
                DestinationCidrBlock=default_route_cidr,
                InstanceId=ec2_instance_id
            )

            print(f'Disabling source / dest check on EC2 instance. We cannot do this in TerraForm when using an ASG.')
            ec2_client.modify_instance_attribute(InstanceId=ec2_instance_id, SourceDestCheck={'Value': False})
        else:
            print(f'Only cleanup required, not adding new routes.')

    scaling.complete_lifecycle_action(
        LifecycleHookName=eventDetail['LifecycleHookName'],
        LifecycleActionToken=eventDetail['LifecycleActionToken'],
        AutoScalingGroupName=eventDetail['AutoScalingGroupName'],
        LifecycleActionResult='CONTINUE',
        InstanceId=eventDetail['EC2InstanceId']
    )

# f = open("test.json", "r")
# event = json.loads(f.read())
# f.close()

# lambda_handler(event, 0)
