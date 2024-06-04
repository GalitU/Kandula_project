from asyncio.log import logger
from click.decorators import FC
import click
from numpy import multiply
import validators
import os
import requests as re
import logging
import sys
import json
import string

logger = None
log_level = None
kandula_url = None
stdout_handler = None


def open_url(ctx, param, value):
    global kandula_url

    try:
        if value is None and validators.url(value):
            return value
        if re.get(value).status_code == 200:
            kandula_url = value
            return value
        else:
            raise re.exceptions.HTTPError(f"Web site {value} is not active")
    except ValueError as err:
        logger.critical(f'Error: Could not parse web site address "{value}", ({err})')
        raise err
    except re.exceptions.HTTPError as err:
        raise re.exceptions.HTTPError(f'Could not access to web site address "{value}", ({err})')
    except Exception as err:
        logger.critical(f'Error: General error in validate web site address "{value}", ({err})')
        raise err


def init_kandula_logging():
    global logger, stdout_handler

    logger = logging.getLogger(__name__)
    FORMAT = "[%(asctime)s %(filename)-13s->%(funcName)s():%(lineno)-4s]-[%(levelname)-7s]: %(message)s"
    logging.basicConfig(filename='kandulacli.log', format=FORMAT, level='DEBUG')
    # std out - instead of print
    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setLevel(logging.DEBUG)
    stdout_handler.setFormatter(logging.Formatter("%(message)s"))
    logger.addHandler(stdout_handler)


def set_log_level(ctx, param, value):
    global logger, log_level, stdout_handler

    if value:
        log_level = "DEBUG"
        logger.setLevel(log_level)
        stdout_handler.setLevel("INFO")
    else:
        log_level = "INFO"
        logger.setLevel(log_level)
    logger.debug("Log level increased to DEBUG") if value else logger.debug("Log level is INFO")

def validate_force(ctx, param, value):
    if value:
        return value
    else:
        validate = input("Are you sure you want terminate all listed instances [Yes/No]: ")
        if validate.upper() == ("YES"):
            return True
        else:
            raise Exception(f"termination is stopped")

def validate_id(ctx, param, value):
    for instance in value:
        if instance[0:2] != "i-":
            raise Exception(f"instance ID {instance} is invalid, should start from 'i-'")
        if len(instance) != 19:
            raise Exception(
                f"lenght of instance ID {instance} is invalid, should be in format [i-<17 characters in hexa only>]")
        if not all(c in string.hexdigits for c in instance[2:]):
            raise Exception(f"instance ID {instance} is invalid, should be in format [i-<17 characters in hexa only>]")
    return value

# --------------------------------------------------


@click.group()
def cli():
    pass


def get_instances_from_kandula(user, password):
    try:
        data = re.post(kandula_url + '/raw_instances', data={'user_name': user, 'user_password': password})
        instances = json.loads(data.content.decode("utf-8"))
        return instances
    except Exception as ex:
        raise Exception(f"Could not receive list of instances, ({ex})")


def print_instance_info(instance):
    for tag in instance['Tags']:
        if tag['Key'].upper() == 'NAME':
            logger.info(f"\n{instance['Id']} - {tag['Value']}")
            logger.info(f"=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=")
            break

    logger.info(f"State :              {instance['State']}")
    if instance['State'] != "running":
        logger.info(f"State Reason:        {instance['StateReason']}")

    logger.info(f"Cloud :              {instance['Cloud']}")
    logger.info(f"Region :             {instance['Region']}")
    logger.info(f"Type :               {instance['Type']}")
    logger.info(f"ImageId :            {instance['ImageId']}")
    logger.info(f"LaunchTime :         {instance['LaunchTime']}")
    logger.info(f"SubnetId :           {instance['SubnetId']}")
    logger.info(f"VpcId :              {instance['VpcId']}")
    logger.info(f"MacAddress :         {instance['MacAddress']}")
    logger.info(f"NetworkInterfaceId : {instance['NetworkInterfaceId']}")
    logger.info(f"PrivateDnsName :     {instance['PrivateDnsName']}")
    logger.info(f"PrivateIpAddress :   {instance['PrivateIpAddress']}")
    logger.info(f"PublicDnsName :      {instance['PublicDnsName']}")
    logger.info(f"PublicIpAddress :    {instance['PublicIpAddress']}")
    logger.info(f"RootDeviceName :     {instance['RootDeviceName']}")
    logger.info(f"RootDeviceType :     {instance['RootDeviceType']}")
    logger.info(f"Security groups :")
    for sg in instance['SecurityGroups']:
        logger.info(f"           {sg['GroupName']}")

    logger.info(f"Tags :")
    for tag in instance['Tags']:
        logger.info(f"           {tag['Key']} : {tag['Value']}")

# ---------------------------


@cli.command(name='get_instances')
@click.option('--debug', '-d', is_flag=True, default=False, help='Add more debug info.', callback=set_log_level)
@click.option('--url', '-u', help='Web address of site. Example : https://kandula.galitu.sites', callback=open_url)
@click.option('--user', help='User name with which Kandula application is started')
@click.option('--password', '-p', help='Password with which Kandula application is started')
def get_instances(url, user, password, debug):
    logger.info(f"get_instances will be executed for url = {kandula_url} with log level = {log_level}")
    instances = get_instances_from_kandula(user, password)
    logger.debug(json.dumps(instances, indent=4, sort_keys=True))
    for instance in instances['Instances']:
        for tag in instance['Tags']:
            if tag['Key'].upper() == 'NAME':
                logger.info(f"{instance['Id']} - {tag['Value']}")
                break
        else:
            logger.info(f"{instance['Id']}")

# ---------------------------


@cli.command(name='get_instance')
@click.option('--debug', '-d', is_flag=True, default=False, help='Add more debug info.', callback=set_log_level)
@click.option('--url', '-u', help='Web address of site. Example : https://kandula.galitu.sites', required=True, callback=open_url)
@click.option('--user', help='User name with which Kandula application is started', required=True)
@click.option('--password', '-p', help='Password with which Kandula application is started', required=True)
@click.option('--instance', '-i', type=str, multiple=True, required=True,
              help='Instance ID, can be multiple. Example: -i i-078981293233d0fed -i i-0ab0fe580b92e2f26',
              callback=validate_id)
def get_instance(debug, url, instance, user, password):
    aws_instances = get_instances_from_kandula(user, password)
    for aws_inst in aws_instances['Instances']:
        for relevant_ins in instance:
            if aws_inst['Id'] == relevant_ins:
                print_instance_info(aws_inst)


def action(instance, user, password, action_name, state_1, state_2):
    aws_instances = get_instances_from_kandula(user, password)
    for aws_inst in aws_instances['Instances']:
        for relevant_ins in instance:
            if aws_inst['Id'] == relevant_ins:
                response = re.post(kandula_url + f'/instances/{relevant_ins}/{action_name}',
                                   data={'instanceId': relevant_ins, 'user_name': user, 'user_password': password})
    # Validate after action
    aws_instances = get_instances_from_kandula(user, password)
    for aws_inst in aws_instances['Instances']:
        for relevant_ins in instance:
            if aws_inst['Id'] == relevant_ins:
                if (aws_inst['State'] == state_1 or aws_inst['State'] == state_2):
                    logger.info(
                        f"{action_name} {relevant_ins} succeeded, current instance state is {aws_inst['State']}")
                else:
                    logger.error(f"Error: {action_name} {relevant_ins} failed, current instance state is {aws_inst['State']}")


# ---------------------------
@cli.command(name='stop_instance')
@click.option('--debug', '-d', is_flag=True, default=False, help='Add more debug info.', callback=set_log_level)
@click.option('--url', '-u', help='Web address of site. Example : https://kandula.galitu.sites', required=True, callback=open_url)
@click.option('--user', help='User name with which Kandula application is started', required=True)
@click.option('--password', '-p', help='Password with which Kandula application is started', required=True)
@click.option('--instance', '-i', type=str, multiple=True, required=True,
              help='Instance ID, can be multiple. Example: -i i-078981293233d0fed -i i-0ab0fe580b92e2f26',
              callback=validate_id)
def stop(debug, url, instance, user, password):
    action(instance, user, password, "stop", "stopped", "stopping")

# ---------------------------
@cli.command(name='start_instance')
@click.option('--debug', '-d', is_flag=True, default=False, help='Add more debug info.', callback=set_log_level)
@click.option('--url', '-u', help='Web address of site. Example : https://kandula.galitu.sites', required=True, callback=open_url)
@click.option('--user', help='User name with which Kandula application is started', required=True)
@click.option('--password', '-p', help='Password with which Kandula application is started', required=True)
@click.option('--instance', '-i', type=str, multiple=True, required=True,
              help='Instance ID, can be multiple. Example: -i i-078981293233d0fed -i i-0ab0fe580b92e2f26')
def start(debug, url, instance, user, password):
    action(instance, user, password, "start", "pending", "running")

# ---------------------------


@cli.command(name='terminate_instance')
@click.option('--debug', '-d', is_flag=True, default=False, help='Add more debug info.', callback=set_log_level)
@click.option('--force', '-f', is_flag=True, default=False, help='Force flag', callback=validate_force)
@click.option('--url', '-u', help='Web address of site. Example : https://kandula.galitu.sites', required=True, callback=open_url)
@click.option('--user', help='User name with which Kandula application is started', required=True)
@click.option('--password', '-p', help='Password with which Kandula application is started', required=True)
@click.option('--instance', '-i', type=str, multiple=True, required=True,
              help='Instance ID, can be multiple. Example: -i i-078981293233d0fed -i i-0ab0fe580b92e2f26')
def terminate(debug, url, force, instance, user, password):
    action(instance, user, password, "terminate", "shutting-down", "terminated")

if __name__ == '__main__':
    try:
        init_kandula_logging()
        cli()
    except Exception as ex:
        logger.critical(f"Error: {ex}")
