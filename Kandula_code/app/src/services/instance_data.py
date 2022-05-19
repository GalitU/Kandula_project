from ast import Try
from textwrap import indent
from boto3 import client
import logging
import json
from collections import OrderedDict

logger = logging.getLogger()

SAMPLE_INSTANCE_DATA = {
    'Instances': [
        {'Cloud': 'aws', 'Region': 'eu-central-1', 'Id': 'i-53d13a927070628de', 'Type': 'a1.2xlarge',
         'ImageId': 'ami-03cf127a',
         'LaunchTime': '2020-10-13T19:27:52.000Z', 'State': 'running',
         'StateReason': None, 'SubnetId': 'subnet-3c940491', 'VpcId': 'vpc-9256ce43',
         'MacAddress': '1b:2b:3c:4d:5e:6f', 'NetworkInterfaceId': 'eni-bf3adbb2',
         'PrivateDnsName': 'ip-172-31-16-58.ec2.internal', 'PrivateIpAddress': '172.31.16.58',
         'PublicDnsName': 'ec2-54-214-201-8.compute-1.amazonaws.com', 'PublicIpAddress': '54.214.201.8',
         'RootDeviceName': '/dev/sda1', 'RootDeviceType': 'ebs',
         'SecurityGroups': [{'GroupName': 'default', 'GroupId': 'sg-9bb1127286248719d'}],
         'Tags': [{'Key': 'Name', 'Value': 'Jenkins Master'}]
         },
        {'Cloud': 'aws', 'Region': 'eu-central-1', 'Id': 'i-23a13a927070342ee', 'Type': 't2.medium',
         'ImageId': 'ami-03cf127a',
         'LaunchTime': '2020-10-18T21:27:49.000Z', 'State': 'Stopped',
         'StateReason': 'Client.UserInitiatedShutdown: User initiated shutdown', 'SubnetId': 'subnet-3c940491', 'VpcId': 'vpc-9256ce43',
         'MacAddress': '1b:2b:3c:4d:5e:6f', 'NetworkInterfaceId': 'eni-bf3adbb2',
         'PrivateDnsName': 'ip-172-31-16-58.ec2.internal', 'PrivateIpAddress': '172.31.16.58',
         'PublicDnsName': 'ec2-54-214-201-8.compute-1.amazonaws.com', 'PublicIpAddress': '54.214.201.8',
         'RootDeviceName': '/dev/sda1', 'RootDeviceType': 'ebs',
         'SecurityGroups': [{'GroupName': 'default', 'GroupId': 'sg-9bb1127286248719d'}],
         'Tags': [{'Key': 'Name', 'Value': 'Consul Node'}]
         },
        {'Cloud': 'aws', 'Region': 'eu-central-1', 'Id': 'i-77z13a9270708asd', 'Type': 't2.xlarge',
         'ImageId': 'ami-03cf127a',
         'LaunchTime': '2020-10-18T21:27:49.000Z', 'State': 'Running',
         'StateReason': None, 'SubnetId': 'subnet-3c940491', 'VpcId': 'vpc-9256ce43',
         'MacAddress': '1b:2b:3c:4d:5e:6f', 'NetworkInterfaceId': 'eni-bf3adbb2',
         'PrivateDnsName': 'ip-172-31-16-58.ec2.internal', 'PrivateIpAddress': '172.31.16.58',
         'PublicDnsName': 'ec2-54-214-201-8.compute-1.amazonaws.com', 'PublicIpAddress': '54.214.201.8',
         'RootDeviceName': '/dev/sda1', 'RootDeviceType': 'ebs',
         'SecurityGroups': [{'GroupName': 'default', 'GroupId': 'sg-9bb1127286248719d'}],
         'Tags': [{'Key': 'Name', 'Value': 'Grafana'}]
         }
    ]
}


class InstanceData:
    def __init__(self, ec2_client: client):
        self.ec2_client = ec2_client
        self.formatted_response_list = {'Instances': []}

    def get_value(self, object, name_of_value, instance_id):
        result = ""
        try:
            result = object[name_of_value]
            logger.debug("GALITU: Element %s = %s in instance %s",
                         name_of_value, result, instance_id)
        except:
            logger.warning("GALITU: Element %s not exist in instance %s",
                           name_of_value, instance_id)
        finally:
            return result

    def parse_response_to_relevant_format(self, response_from_boto3):
        try:
            count = 0
            for reservation in response_from_boto3['Reservations']:
                for instance in reservation['Instances']:
                    logger.debug(
                        "GALITU: Count %d, instance from boto [%s]", count, instance)
                    logger.info("GALITU: Count %d instance ID %s",
                                count, instance[u'InstanceId'])
                    formatted_instance = {}
                    count = count + 1
                    formatted_instance['Cloud'] = 'aws'
                    formatted_instance['Region'] = self.ec2_client.meta.region_name
                    formatted_instance['Id'] = self.get_value(
                        instance, u'InstanceId', instance[u'InstanceId'])
                    formatted_instance['Type'] = self.get_value(
                        instance, u'InstanceType', instance[u'InstanceId'])
                    formatted_instance['ImageId'] = self.get_value(
                        instance, u'ImageId', instance[u'InstanceId'])
                    formatted_instance['LaunchTime'] = self.get_value(
                        instance, u'LaunchTime', instance[u'InstanceId'])
                    state = self.get_value(instance[u'State'],
                                           u'Name', instance[u'InstanceId'])
                    stateReason = self.get_value(
                        instance, u'StateReason', instance[u'InstanceId'])
                    stateReasonMessage = None
                    if (stateReason != ""):
                        stateReasonMessage = self.get_value(
                            instance[u'StateReason'], u'Message', instance[u'InstanceId'])
                    formatted_instance['State'] = state
                    formatted_instance['StateReason'] = stateReasonMessage if state != "running" else None
                    formatted_instance['SubnetId'] = self.get_value(
                        instance, u'SubnetId', instance[u'InstanceId'])
                    formatted_instance['VpcId'] = self.get_value(
                        instance, u'VpcId', instance[u'InstanceId'])
                    formatted_instance['RootDeviceName'] = self.get_value(
                        instance, u'RootDeviceName', instance[u'InstanceId'])
                    formatted_instance['RootDeviceType'] = self.get_value(
                        instance, u'RootDeviceType', instance[u'InstanceId'])
                    formatted_instance['SecurityGroups'] = self.get_value(
                        instance, u'SecurityGroups', instance[u'InstanceId'])
                    formatted_instance['Tags'] = self.get_value(
                        instance, u'Tags', instance[u'InstanceId'])
                    formatted_instance['MacAddress'] = "" if len(instance[u'NetworkInterfaces']) == 0 else self.get_value(
                        instance[u'NetworkInterfaces'][0], u'MacAddress', instance[u'InstanceId'])
                    formatted_instance['NetworkInterfaceId'] = "" if len(instance[u'NetworkInterfaces']) == 0 else self.get_value(
                        instance[u'NetworkInterfaces'][0], u'NetworkInterfaceId', instance[u'InstanceId'])
                    formatted_instance['PrivateDnsName'] = "" if len(instance[u'NetworkInterfaces']) == 0 else self.get_value(
                        instance[u'NetworkInterfaces'][0], u'PrivateDnsName', instance[u'InstanceId'])
                    formatted_instance['PrivateIpAddress'] = "" if len(instance[u'NetworkInterfaces']) == 0 else self.get_value(
                        instance[u'NetworkInterfaces'][0], u'PrivateIpAddress', instance[u'InstanceId'])
                    formatted_instance['PublicDnsName'] = "" if len(instance[u'NetworkInterfaces']) == 0 else self.get_value(
                        instance, u'PublicDnsName', instance[u'InstanceId'])
                    formatted_instance['PublicIpAddress'] = "" if len(instance[u'NetworkInterfaces']) == 0 else self.get_value(
                        instance, u'PublicIpAddress', instance[u'InstanceId'])

                    self.formatted_response_list['Instances'].append(
                        formatted_instance)

        except Exception as error:
            error_string = str(error)
            logger.fatal(
                "GALITU: parse_response_to_relevant_format() - error is %s", error_string)

        finally:
            return self.formatted_response_list

    def get_and_format_instances_from_aws(self):
        self.formatted_response_list = {'Instances': []}
        try:
            response = self.ec2_client.describe_instances()
            if response['ResponseMetadata']['HTTPStatusCode'] == 200:
                logger.info(
                    "GALITU: Connection to AWS succeeded with status %d", response['ResponseMetadata']['HTTPStatusCode'])

                self.formatted_response_list = self.parse_response_to_relevant_format(
                    response)
            else:
                logger.info(
                    "GALITU: Connection to AWS FAILED with status %d", response['ResponseMetadata']['HTTPStatusCode'])
        except Exception as error:
            error_string = str(error)
            logger.error(
                "GALITU: There was connection problem to AWS [%s]", error_string)
        finally:
            return self.formatted_response_list

    def get_instances(self):
        received_instances = self.get_and_format_instances_from_aws()
        logger.debug("GALITU ===>>> %s", received_instances)
        return received_instances


#######################################################
# For debug only
#kuku = InstanceData(client('ec2'))
#response = kuku.get_instances()
# print(response)
