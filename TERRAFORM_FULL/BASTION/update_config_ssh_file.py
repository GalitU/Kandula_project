from genericpath import exists
import os
import re
from jinja2 import Template
import os.path


# wget http://lb-jenkins-mprj-kandula-1740977339.eu-central-1.elb.amazonaws.com/jnlpJars/jenkins-cli.jar

bastion_terraform_address = os.popen("terraform output bastion_server_public_ip").read(
).replace("'", "").replace('"', '').replace('\n', '')
print("\n\n-----------------------\nUpdate Bastion public IP = ",
      bastion_terraform_address, " in config SSH file", end="\n\n\n")
script_dir = os.path.abspath(os.path.dirname(__file__))
template_file = open(script_dir + "/config.j2", "r")

template_text = template_file.read()
tm = Template(template_text)
bastion_ip_registration = tm.render(
    BASTION_PUBLIC_IP=bastion_terraform_address)
print(bastion_ip_registration, end="\n\n\n")

with open(script_dir + "/config", mode="wt") as f:
    f.write(bastion_ip_registration)

print("~/.ssh/config file was updated IP of Bastion host, IP = ",
      bastion_ip_registration, end="\n\n")
