#! /bin/bash

apt update
apt install awscli -y
local_aws_hostname=$(curl http://169.254.169.254/latest/meta-data/local-hostname)

# Code for install/start NGinx web server and change the welcome web page
#apt install nginx  -y

Host *.eu-central-1.compute.amazonaws.com
    Hostname 10.0.11.213
    Port 22
    User ubuntu
    ProxyCommand ssh -p22 ubuntu@`aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Task,Values=Mid_prj" "Name=tag:Name,Values=Mid_prj ansible Server Ubuntu_1" | jq -r .Reservations[].Instances[].PrivateIpAddress` nc %h %p
	IdentityFile ~/.ssh/Key_Mid_prj_ansible.pem
 ForwardAgent yes

#echo "<body style=\"background-color: white;\"><font color=\"blue\"><center><br><br><br><br><br><br><br><br><h1>Welcome to Grandpa's Whiskey at $hostname<br><br>Local hostname = $local_aws_hostname</h1></center></font></body>" | sudo tee /var/www/html/index.html
#systemctl enable nginx
#systemctl start nginx
#systemctl status nginx

#sudo sh -c 'echo "#!/bin/bash \nsudo aws s3 cp /var/log/nginx/access.log s3://s3-ops-vpc-dev-bucket/$(hostname)/access.log" > /etc/cron.hourly/copy_web_access_logs_to_s3.sh'
#sudo chmod +x /etc/cron.hourly/copy_web_access_logs_to_s3.sh
