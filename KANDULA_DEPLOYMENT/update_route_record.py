import subprocess
from genericpath import exists
import os
from jinja2 import Template
import os.path
import requests
import time
import sys
import getopt
import traceback

lb_address = None
route_record_name = None
host_zone_id = None
site = None
script_dir = os.path.abspath(os.path.dirname(__file__))


def update_record():
    global lb_address, route_record_name, host_zone_id, script_dir, site
    route_template_key_file = open(script_dir + "/" + "route_update.j2", "r")
    route_template_key_file_content = route_template_key_file.read()

    tm = Template(route_template_key_file_content)

    change_rioute_for_node_json = tm.render(
        HOSTED_ZONE_NAME=route_record_name, LB_ADDRESS=lb_address, SITE_NAME=site)
    print(change_rioute_for_node_json, end="\n\n\n")

    record_json_file = script_dir + "/route_record.json"
    with open(record_json_file, mode="wt") as f:
        f.write(change_rioute_for_node_json)

    cmd = 'aws route53 change-resource-record-sets --hosted-zone-id {} --change-batch "file://{}"'.format(host_zone_id,
                                                                                                          record_json_file
                                                                                                          )
    print(cmd, end="\n")
    return os.popen(cmd).read().replace("'", "").replace('"', '').replace('\n', '')


def PrintUsage():
    print("\nUsage:")
    print('\t\tupdata_ssh_key.py -l <address of LB> -n <record name> -z <host zone ID> -s <your root site address>')
    print("Example : ")
    print('\t\tupdate_route_record.py -l afd4695d6ee804f4dfhsfdghsjf801f92d-68e5623d6873d37f.elb.eu-central-1.amazonaws.com -n "my-kandula" -z "534535S2353u6YN" -s "my_site.com')


def get_params(argv):
    global lb_address, route_record_name, host_zone_id, site

    if len(argv) == 0:
        print("Error: Invalid input")
        PrintUsage()
        sys.exit(1)

    try:
        options, args = getopt.getopt(
            argv, "l:n:z:s:", ["lb=", "name=", "zone=", "site", "help"])
        for (option_key, option_value) in options:
            match option_key:
                case '--help':
                    PrintUsage()
                    sys.exit(1)
                case '--lb':
                    lb_address = option_value
                case '-l':
                    lb_address = option_value
                case '--name':
                    route_record_name = option_value
                case '-n':
                    route_record_name = option_value
                case '--zone':
                    host_zone_id = option_value
                case '-z':
                    host_zone_id = option_value
                case '--site':
                    site = option_value
                case '-s':
                    site = option_value

                case _:
                    print("Error: Invalid input")
                    PrintUsage()

    except getopt.GetoptError:
        traceback.print_exc()
        PrintUsage()
        sys.exit(2)


# aws route53 change-resource-record-sets - -hosted-zone-id Z06370712F3OMF8G17950 - -change-batch file://change-config.json

def main(argv):
    get_params(argv)
    result = update_record()
    print(result)
    print('Now you can start use you your site {}.{} now'.format(
        route_record_name, site))


if __name__ == "__main__":
    main(sys.argv[1:])
