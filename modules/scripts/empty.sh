#! /bin/bash

# Code for install/start NGinx web server and change the welcome web page
apt update
apt install nginx  -y
apt install awscli -y

local_aws_hostname=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
