#! /bin/bash

# Code for install/start NGinx web server and change the welcome web page
apt update
apt install awscli -y

# Set ansible key
#echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrQe20EN5U2aBkD0NEGBWPb9b4OeTof/yfsh/dLgdfwu2D7SGBxwGt4JLOiT0XgW4z2cuH5WUu4xe9e+jGDxYztP+zKtqSSYYE++1NREzA5aDgn8GX792+oxlkpeVddpUFPUK2qEXPsBHbJ5T5hNspqzeYhU6syxaJrIVd0CYu0SFiGrA2QDiMNPn/Q5z5IQSRsCarcBO8NKets47l9WKzCcBrL1xalOUcjz1rp5th25LsoBHpAZaGY1Ipm2iYhaXAx06sJDa+6jPnO/YZyEybldJAmrVZXCww2emtlV5VagzLae/T6GO+0dXTBruuksySzg7pgzdq8b3vhMutNq+rADaWtOMZZWM8FR4KYE8IVSMi6bv9Z63hivfhoPwh9+q1iePzQnmn922VdnzjL/t8ahU2udydwfGHXwLl75XEBnnWQSfZO9oMbxjfwR7KOMepESme4PBp1H4MB2feBUisX3Hd3PQ4111DyYUdAmZE96TaLJQEDGhOz0fIPZi7M+c= ubuntu@ip-10-0-4-214
#" > ~/ansible_key.pub
#cat ~/ansible_key.pub >> ~/.ssh/authorized_keys

local_aws_hostname=$(curl http://169.254.169.254/latest/meta-data/local-hostname)

## apt install nginx  -y
#echo "<body style=\"background-color: white;\"><font color=\"blue\"><center><br><br><br><br><br><br><br><br><h1>Welcome to Grandpa's Whiskey at $hostname<br><br>Local hostname = $local_aws_hostname</h1></center></font></body>" | sudo tee /var/www/html/index.html
#systemctl enable nginx
#systemctl start nginx
#systemctl status nginx

#sudo sh -c 'echo "#!/bin/bash \nsudo aws s3 cp /var/log/nginx/access.log s3://s3-ops-vpc-dev-bucket/$(hostname)/access.log" > /etc/cron.hourly/copy_web_access_logs_to_s3.sh'
#sudo chmod +x /etc/cron.hourly/copy_web_access_logs_to_s3.sh

sudo apt-get update -y
sudo apt install software-properties-common
sudo apt-get install python3 -y
sudo apt-get install python3-pip -y
sudo pip3 install boto boto3 click

