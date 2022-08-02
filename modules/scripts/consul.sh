#! /bin/bash

# Set ansible key
sudo apt-get update -y
sudo lsof /var/lib/dpkg/lock
sudo lsof /var/lib/apt/lists/lock
sudo lsof /var/cache/apt/archives/lock
sudo dpkg --configure -a
sudo apt install software-properties-common apt-transport-https -y
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt install openjdk-8-jdk -y
sudo apt install docker.io -y
sudo usermod -a -G docker ubuntu
sudo apt-get install python3 -y
sudo apt-get install python3-pip -y
sudo pip3 install boto boto3 click
sudo apt-get install awscli -y
sudo pip install --upgrade awscli

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrQe20EN5U2aBkD0NEGBWPb9b4OeTof/yfsh/dLgdfwu2D7SGBxwGt4JLOiT0XgW4z2cuH5WUu4xe9e+jGDxYztP+zKtqSSYYE++1NREzA5aDgn8GX792+oxlkpeVddpUFPUK2qEXPsBHbJ5T5hNspqzeYhU6syxaJrIVd0CYu0SFiGrA2QDiMNPn/Q5z5IQSRsCarcBO8NKets47l9WKzCcBrL1xalOUcjz1rp5th25LsoBHpAZaGY1Ipm2iYhaXAx06sJDa+6jPnO/YZyEybldJAmrVZXCww2emtlV5VagzLae/T6GO+0dXTBruuksySzg7pgzdq8b3vhMutNq+rADaWtOMZZWM8FR4KYE8IVSMi6bv9Z63hivfhoPwh9+q1iePzQnmn922VdnzjL/t8ahU2udydwfGHXwLl75XEBnnWQSfZO9oMbxjfwR7KOMepESme4PBp1H4MB2feBUisX3Hd3PQ4111DyYUdAmZE96TaLJQEDGhOz0fIPZi7M+c= ubuntu@ip-10-0-4-214" > ~/ansible_key.pub
cat ~/ansible_key.pub >> ~/.ssh/authorized_keys

local_aws_hostname=$(curl http://169.254.169.254/latest/meta-data/local-hostname)


wget -O ~/jenkins-cli.jar --no-check-certificate https://jenkins.galitu.site/jnlpJars/jenkins-cli.jar
java -jar ~/jenkins-cli.jar -s https://jenkins.galitu.site/ -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -webSocket build Ansible_Consul_Install -s -v
java -jar ~/jenkins-cli.jar -s https://jenkins.galitu.site/ -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -webSocket build Ansible_NodeExporter_Install -s -v
