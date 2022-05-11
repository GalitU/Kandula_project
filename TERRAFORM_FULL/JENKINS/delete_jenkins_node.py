import os
import re
from jinja2 import Template
import os.path

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
    print("\n\n-----------------------\nUnRegister Node JenkinsAgent_", str(i), " with ip = ", ip,  end="\n")
    cmd = 'java -jar jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s ' + \
        jenkins_lb_url_for_register + \
        " -webSocket delete-node JenkinsAgent_" + str(i)
    i = i + 1
    print(cmd, end="\n")
    os.system(cmd)
