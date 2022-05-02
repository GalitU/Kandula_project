#! /bin/bash

# Code for install/start NGinx web server and change the welcome web page
apt update
apt install nginx  -y
apt install awscli -y

local_aws_hostname=$(curl http://169.254.169.254/latest/meta-data/local-hostname)

echo "<body style=\"background-color: white;\"><font color=\"blue\"><center><br><br><br><br><br><br><br><br><h1>Welcome to Grandpa's Whiskey at $hostname<br><br>Local hostname = $local_aws_hostname</h1></center></font></body>" | sudo tee /var/www/html/index.html
systemctl enable nginx
systemctl start nginx
systemctl status nginx

#sudo sh -c 'echo "#!/bin/bash \nsudo aws s3 cp /var/log/nginx/access.log s3://s3-ops-vpc-dev-bucket/$(hostname)/access.log" > /etc/cron.hourly/copy_web_access_logs_to_s3.sh'
#sudo chmod +x /etc/cron.hourly/copy_web_access_logs_to_s3.sh
