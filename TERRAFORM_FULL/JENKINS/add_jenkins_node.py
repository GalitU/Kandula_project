from genericpath import exists
import os
import re
from jinja2 import Template
import os.path
import requests
import time
import sys

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
        time.sleep(0.5)
        response = requests.get(jenkins_lb_url)
        #print(response.content, end="\n\n")
        if response.status_code == 200 or response.status_code == 403 and 'Authentication required' in response.content.decode('utf-8'):
            return True
        else:
            print("Wait 500 miliseconds for Jenkins UP and Running . . .", end="\n")


def get_jenkins_address():
    global jenkins_lb_url_for_register, jenkins_lb_url

    #lb_terraform_address = os.popen(
    #    "terraform output jenkins_alb_dns").read().replace("'", "").replace('"', '').replace('\n', '')
    #print("\n\n-----------------------\nJenkins ALB dns = ",
    #      lb_terraform_address, end="\n")
   ###jenkins_lb_url_for_register = 'http://' + lb_terraform_address
   ###jenkins_lb_url = 'http://' + lb_terraform_address + '/jnlpJars/jenkins-cli.jar'
    jenkins_lb_url_for_register = 'https://jenkins.galitu.site'
    jenkins_lb_url = 'https://jenkins.galitu.site' + \
        '/jnlpJars/jenkins-cli.jar'

    print("Jenkins address is ", jenkins_lb_url_for_register, end="\n")


def get_jar_file():
    global jenkins_lb_url_for_register, jenkins_lb_url

    print("Jenkins CLI file will be received from ", jenkins_lb_url, end="\n")
    if not os.path.exists('~/jenkins-cli.jar'):
        print("File ~/ will be downloaded from Jenkins server", end="\n")
        os.system(
            "wget -O ~/jenkins-cli.jar --no-check-certificate " + jenkins_lb_url)
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

            cmd = 'cat jenkins_node.xml | java -Djavax.net.ssl.trustStore=cacerts -jar ~/jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s ' + \
                jenkins_lb_url_for_register + \
                " -webSocket create-node JenkinsAgent_" + str(i)
            i = i + 1
            print(cmd, end="\n")
            os.system(cmd)


def decrease_unused_nodes():
    global jenkins_lb_url_for_register, jenkins_lb_url

    # in case when we decreased number of servers
    for i in range(total_number_for_cleaning):
        cmd = 'java -Djavax.net.ssl.trustStore=cacerts -jar ~/jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s ' + \
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
            cmd = 'java -Djavax.net.ssl.trustStore=cacerts -jar ~/jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s ' + \
                jenkins_lb_url_for_register + \
                " -webSocket delete-node JenkinsAgent_" + str(i)
            print(cmd, end="\n")
            os.system(cmd)

        print("\n\n=-=-=-=-=-=", "Finished you can open your jenkins server now by click on ",
              jenkins_lb_url_for_register, end="\n\n")

# wget --no-check-certificate https://jenkins.galitu.site/jnlpJars/jenkins-cli.jar


def update_agent_credentials_ssh_private_key_by_script():
    script_dir_local = "."

    cmd = 'python3 {}/../UPDATE_SECRETS/updata_ssh_key.py -i "slaves_ssh_key" -d "slaves_ssh_key" -s "{}/../KEYS/Key_Master_Kandula_FPrj.pem" -f "{}/../UPDATE_SECRETS/ssh_secret_key.j2" -u "ubuntu" -a {}'.format(
        script_dir_local, script_dir_local, script_dir_local, 'https://jenkins.galitu.site')
    print(cmd, end="\n")
    change_credentials_ssh_jenkins_result = os.popen(cmd).read()
    print(change_credentials_ssh_jenkins_result, end="\n")


def main(argv):
    get_jenkins_address()
    validate_jenkins_server_is_up_and_running()
    get_jar_file()
    update_agent_credentials_ssh_private_key_by_script()
    decrease_unused_nodes()
    add_nodes()


if __name__ == "__main__":
    main(sys.argv[1:])
