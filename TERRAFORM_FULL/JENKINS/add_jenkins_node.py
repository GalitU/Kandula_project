from genericpath import exists
import os
import re
from jinja2 import Template
import os.path
import jinja2
import requests
import time

total_number_for_cleaning = 2
jenkins_lb_url_for_register = None
jenkins_lb_url = None
terraform_agent_ip_arr = None


def validate_jenkins_server_is_up_and_running():
    global jenkins_lb_url
    response = requests.get(jenkins_lb_url)
    # print(response.content)
    if response.status_code == 200 or response.status_code == 403 and 'Authentication required' in response.content.decode('utf-8'):
        return True
    while True:
        time.sleep(1.5)
        response = requests.get(jenkins_lb_url)
        #print(response.content, end="\n\n")
        if response.status_code == 200 or response.status_code == 403 and 'Authentication required' in response.content.decode('utf-8'):
            return True
        else:
            print("Wait 500 miliseconds for Jenkins UP and Running . . .", end="\n")


def get_jenkins_address():
    global jenkins_lb_url_for_register, jenkins_lb_url

    lb_terraform_address = os.popen(
        "terraform output jenkins_alb_dns").read().replace("'", "").replace('"', '').replace('\n', '')
    print("\n\n-----------------------\nJenkins ALB dns = ",
          lb_terraform_address, end="\n")
    jenkins_lb_url_for_register = 'http://' + lb_terraform_address
    jenkins_lb_url = 'http://' + lb_terraform_address + '/jnlpJars/jenkins-cli.jar'
    print("Jenkins address is ", jenkins_lb_url_for_register, end="\n")


def get_jar_file():
    global jenkins_lb_url_for_register, jenkins_lb_url

    print("Jenkins CLI file will be received from ", jenkins_lb_url, end="\n")
    if not os.path.exists('jenkins-cli.jar'):
        print("File jenkins-cli.jar will be downloaded from Jenkins server", end="\n")
        os.system("wget " + jenkins_lb_url)
    else:
        print("File jenkins-cli.jar exits locally", end="\n")


def add_nodes():
    global jenkins_lb_url_for_register, jenkins_lb_url, terraform_agent_ip_arr

    print("\n\n-----------------------\nGet all private IP of jenkins servers", end="\n")
    result_ip = os.popen("terraform output jenkins_slaves_private_ip").read()

    terraform_agent_ip_arr = re.findall(
        "(.*) = jenkins_pvt_ip_address", result_ip)
    print("List of IPs  ", terraform_agent_ip_arr, end="\n")
    i = 0
    for ip in terraform_agent_ip_arr:
        if len(ip):
            print("\n\n-----------------------\nRegister Node #",
                  str(i), " with IP ", ip,  end="\n")
            template_file = open("jenkins_node_add.j2", "r")
            template_text = template_file.read()
            '''
            print("Template file for register jenkist node is\n",
                template_text, end="\n\n")
            '''
            tm = Template(template_text)

            registration_node_xml = tm.render(
                jenkins_node_id=i, jenkins_node_ip=ip)
            print(registration_node_xml, end="\n\n\n")

            with open("jenkins_node.xml", mode="wt") as f:
                f.write(registration_node_xml)

            cmd = 'cat jenkins_node.xml | java -jar jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s ' + \
                jenkins_lb_url_for_register + \
                " -webSocket create-node JenkinsAgent_" + str(i)
            i = i + 1
            print(cmd, end="\n")
            os.system(cmd)


def decrease_unused_nodes():
    global jenkins_lb_url_for_register, jenkins_lb_url

    # in case when we decreased number of servers
    for i in range(total_number_for_cleaning):
        cmd = 'java -jar jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s ' + \
            jenkins_lb_url_for_register + \
            " -webSocket get-node JenkinsAgent_" + str(i)
        print(cmd, end="\n")
        config_agent = os.popen(cmd).read()
        print(config_agent, end="\n")
        if (len(config_agent)):
            search_result = re.search("<host>(.*)<\/host>", config_agent)
            jenkins_agent_ip = search_result.group(1)
            print(
                "\n\n-----------------------\nDelete unused JenkinsAgent_", str(i), " with ip = ", jenkins_agent_ip, end="\n")
            cmd = 'java -jar jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s ' + \
                jenkins_lb_url_for_register + \
                " -webSocket delete-node JenkinsAgent_" + str(i)
            print(cmd, end="\n")
            os.system(cmd)

        print("\n\n=-=-=-=-=-=", "Finished you can open your jenkins server now by click on ",
              jenkins_lb_url_for_register, end="\n\n")


def update_agent_credentials_ssh_private_key():
    script_dir = os.path.abspath(os.path.dirname(__file__))
    master_key_file = open(
        script_dir + "/../KEYS/Key_Master_Kandula_MPrj.pem", "r")
    master_key_file_content = master_key_file.read()
    cred_template_key_file = open(
        script_dir + "/jenkins_agent_credentials.j2", "r")
    cred_template_key_file_content = cred_template_key_file.read()

    tm = Template(cred_template_key_file_content)

    change_credentials_for_node_xml = tm.render(
        PRIVATE_KEY_AGENT=master_key_file_content)
    print(change_credentials_for_node_xml, end="\n\n\n")

    with open(script_dir + "/jenkins_agent_credentials.xml", mode="wt") as f:
        f.write(change_credentials_for_node_xml)

    cmd = 'cat {} | java -jar jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s {}' \
        ' -webSocket update-credentials-by-xml \"SystemCredentialsProvider::SystemContextResolver::jenkins\" "(global)\" slaves_ssh_key'.format(
            script_dir + "/jenkins_agent_credentials.xml", jenkins_lb_url_for_register)

    print(cmd, end="\n")
    os.system(cmd)


# wget http://lb-jenkins-mprj-kandula-1740977339.eu-central-1.elb.amazonaws.com/jnlpJars/jenkins-cli.jar

def start():
    get_jenkins_address()
    validate_jenkins_server_is_up_and_running()
    get_jar_file()
    update_agent_credentials_ssh_private_key()
    decrease_unused_nodes()
    add_nodes()


# Start the action
start()
