from boto3 import client
import logging

logger = logging.getLogger()


def get_machine_time():
    return 1602824750094  # No need to implement at the moment


def check_aws_connection():
    try:
        ec2 = client('ec2')
        response = ec2.describe_instances()
        ret_status = response['ResponseMetadata']['HTTPStatusCode'] == 200
        logger.info(
            "GALITU: Connection to AWS %s with status %d", "succeeded" if ret_status else "FAILED", response['ResponseMetadata']['HTTPStatusCode'], exc_info=1)
        return ret_status
    except Exception as error:
        error_string = str(error)
        logger.error(
            "GALITU: There was connection problem to AWS [%s]", error_string, exc_info=1)
        return False

def check_db_connection():
    # TODO: implement real select query to db. If successful, return true. otherwise return False
    return True


def is_app_healthy(healthchecks):
    return all([check["Value"] for check in healthchecks])


def get_app_health():
    health_checks = [
        {"Name": "machine-time", "Value": get_machine_time()},
        {"Name": "aws-connection", "Value": check_aws_connection()},
        {"Name": "db-connection", "Value": check_db_connection()},
    ]

    return health_checks, is_app_healthy(health_checks)


# GALITU - for debugging, just activate next function
# check_aws_connection()
