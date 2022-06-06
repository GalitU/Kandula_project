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

total_number_for_cleaning = 2
jenkins_web_address = None
jenkins_cli_web_address = None
terraform_agent_ip_arr = None
secret_id = None
secret_desc = None
secret_value = None
template_file = None
ssh_user_name = None
script_dir = os.path.abspath(os.path.dirname(__file__))
jenkins_cmd_template = 'java -Djavax.net.ssl.trustStore=cacerts -jar ~/jenkins-cli.jar -noCertificateCheck -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s {}' \
    ' -webSocket {} "SystemCredentialsProvider::SystemContextResolver::jenkins" "(global)" {}'


def validate_jenkins_server_is_up_and_running():
    global jenkins_cli_web_address
    response = requests.get(jenkins_cli_web_address)
    # print(response.content)
    if response.status_code == 200 or response.status_code == 403 and 'Authentication required' in response.content.decode('utf-8'):
        return True
    while True:
        time.sleep(0.5)
        response = requests.get(jenkins_cli_web_address)
        #print(response.content, end="\n\n")
        if response.status_code == 200 or response.status_code == 403 and 'Authentication required' in response.content.decode('utf-8'):
            return True
        else:
            print("Wait 500 miliseconds for Jenkins UP and Running . . .", end="\n")


def get_jenkins_address():
    global jenkins_web_address, jenkins_cli_web_address

    jenkins_cli_web_address = jenkins_web_address + \
        '/jnlpJars/jenkins-cli.jar'

    print("Jenkins address is ", jenkins_web_address,
          ", jenkins_cli_web_address = ", jenkins_cli_web_address, end="\n")


def get_jar_file():
    global jenkins_cli_web_address

    print("Jenkins CLI file will be received from ",
          jenkins_cli_web_address, end="\n")
    if not os.path.exists('~/jenkins-cli.jar'):
        print("File ~/jenkins-cli.jar will be downloaded from Jenkins server", end="\n")
        os.system("wget ~/jenkins-cli.jar --no-check-certificate " + jenkins_cli_web_address)
    else:
        print("File ~/jenkins-cli.jar exits locally", end="\n")


def set_secret_key(key_relative_template_filename, command, secret_value, cred_desription, cred_name_template, cred_name, user_name):
    global script_dir
    cred_template_key_file = open(
        script_dir + "/" + key_relative_template_filename, "r")
    cred_template_key_file_content = cred_template_key_file.read()

    tm = Template(cred_template_key_file_content)

    change_credentials_for_node_xml = tm.render(
        CRED_KEY_NAME=cred_name_template, CRED_KEY_NAME_DESC=cred_desription,
        SSH_USER=user_name, PRIVATE_SSH_KEY=secret_value)
    print(change_credentials_for_node_xml, end="\n\n\n")

    with open(script_dir + "/ssh_secret_key.xml", mode="wt") as f:
        f.write(change_credentials_for_node_xml)

    cmd = 'cat {} | '.format(script_dir + "/ssh_secret_key.xml") + \
        jenkins_cmd_template.format(os.path.abspath(os.path.dirname(
            __file__)), jenkins_web_address, command, cred_name)

    print(cmd, end="\n")
    return os.popen(cmd).read().replace("'", "").replace('"', '').replace('\n', '')


def create_secret_key(key_relative_template_filename, secret_value, cred_desription, cred_name, user_name):
    print("Create new ssh key for ID = {}, name {}, user name {}".format(
        cred_desription, cred_name, user_name))
    return set_secret_key(key_relative_template_filename,
                          "create-credentials-by-xml", secret_value, cred_desription, cred_name, '', user_name)


def update_secret_key(key_relative_template_filename, secret_value, cred_desription, cred_name, user_name):
    print("Update exist ssh key for ID = {}, name {}, user name {}".format(
        cred_desription, cred_name, user_name))
    return set_secret_key(key_relative_template_filename, "update-credentials-by-xml", secret_value, cred_desription, cred_name, cred_name, user_name)


def handle_credentials_secret_key(cred_name, secret_value, cred_desription, user_name):
    global script_dir

    cmd = jenkins_cmd_template.format(os.path.abspath(os.path.dirname(
        __file__)), jenkins_web_address, "get-credentials-as-xml", cred_name)

    print(cmd, end="\n")
    result = os.popen(cmd).read().replace(
        "'", "").replace('"', '').replace('\n', '')
    print(result, end="\n\n")
    if "No such credential" in result or result == '':
        return create_secret_key(template_file,
                                 secret_value, cred_desription, cred_name, user_name)
    else:
        return update_secret_key(template_file,
                                 secret_value, cred_desription, cred_name, user_name)


def PrintUsage():
    print("\nUsage:")
    print('\t\tupdata_ssh_key.py -a <address of your Jenkins server> -i <id of secret> -d <description of secret> -s <relative secret file with path> -f <relative path of jinja2 template file with name>')
    print("Example : ")
    print('\t\tupdata_ssh_key.py -a https://jenkins.mysite.com -i "kuku" -d "key for slack" -s "../KEYS/key_1.pem" -f "./secret_key.j2." -u "ubuntu"')


def get_params(argv):
    global secret_id, secret_desc, secret_value, template_file, ssh_user_name, jenkins_web_address

    if len(argv) == 0:
        print("Error: Invalid input")
        PrintUsage()
        sys.exit(1)

    try:
        options, args = getopt.getopt(argv, "i:d:s:f:u:a:", [
                                      "id=", "desc=", "secret_file=", "file=", "ssh_user=", "address=", "help"])
        for (option_key, option_value) in options:
            match option_key:
                case '--help':
                    PrintUsage()
                    sys.exit(1)
                case '--id':
                    secret_id = option_value
                case '-i':
                    secret_id = option_value
                case '--desc':
                    secret_desc = option_value
                case '-d':
                    secret_desc = option_value
                case '--secret_file':
                    master_key_file = open(
                        script_dir + "/" + option_value, "r")
                    secret_value = master_key_file.read()
                case '-s':
                    master_key_file = open(
                        script_dir + "/" + option_value, "r")
                    secret_value = master_key_file.read()
                case '--file':
                    template_file = option_value
                case '-f':
                    template_file = option_value
                case '--ssh_user':
                    ssh_user_name = option_value
                case '-u':
                    ssh_user_name = option_value
                case '--address':
                    jenkins_web_address = option_value
                case '-a':
                    jenkins_web_address = option_value

                case _:
                    print("Error: Invalid input")
                    PrintUsage()

    except getopt.GetoptError:
        traceback.print_exc()
        PrintUsage()
        sys.exit(2)


def main(argv):
    get_params(argv)
    get_jenkins_address()
    validate_jenkins_server_is_up_and_running()
    get_jar_file()
    result = handle_credentials_secret_key(
        secret_id, secret_value, secret_desc, ssh_user_name)
    print(result)
    print('Now you can start use you {}, your key is updated at jenkins, SSH key {} was updated'.format(
        jenkins_web_address, secret_id), end="\n\n")


if __name__ == "__main__":
    main(sys.argv[1:])
