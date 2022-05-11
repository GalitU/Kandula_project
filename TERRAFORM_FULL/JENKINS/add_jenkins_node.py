from genericpath import exists
import os
import re
from jinja2 import Template
import os.path

total_number_for_cleaning = 3

# wget http://lb-jenkins-mprj-kandula-1740977339.eu-central-1.elb.amazonaws.com/jnlpJars/jenkins-cli.jar

lb_terraform_address = os.popen(
    "terraform output jenkins_alb_dns").read().replace("'", "").replace('"', '').replace('\n', '')
print("\n\n-----------------------\nJenkins ALB dns = ",
      lb_terraform_address, end="\n")
jenkins_lb_url_for_register = 'http://' + lb_terraform_address
jenkins_lb_url = 'http://' + lb_terraform_address + '/jnlpJars/jenkins-cli.jar'
print("Jenkins CLI file will be received from ", jenkins_lb_url, end="\n")
if not os.path.exists('jenkins-cli.jar'):
    print("File jenkins-cli.jar will be downloaded from Jenkins server", end="\n")
    os.system("wget " + jenkins_lb_url)
else:
    print("File jenkins-cli.jar exits locally", end="\n")

print("\n\n-----------------------\nGet all private IP of jenkins servers", end="\n")
result_ip = os.popen("terraform output jenkins_slaves_private_ip").read()

ip_arr = re.findall("(.*) = jenkins_pvt_ip_address", result_ip)
print("List of IPs  ", ip_arr, end="\n")
i = 0
for ip in ip_arr:
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
        if jenkins_agent_ip not in ip_arr:
            print(
                "\n\n-----------------------\nDelete unused JenkinsAgent_", str(i), " with ip = ", jenkins_agent_ip, end="\n")
            cmd = 'java -jar jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s ' + \
                jenkins_lb_url_for_register + \
                " -webSocket delete-node JenkinsAgent_" + str(i)
            print(cmd, end="\n")
            os.system(cmd)
        else:
            print("Jenkins node JenkinsAgent_", str(i),
                  " with ip = ", jenkins_agent_ip, " is exist", end="\n")
