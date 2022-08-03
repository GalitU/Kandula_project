#!/bin/bash
set -e
sudo hostnamectl set-hostname "ELKSrv"

echo "INFO: userdata started"

sudo apt update && sudo apt upgrade
sudo apt install default-jdk
sudo apt-get install apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update
sudo apt install elasticsearch
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl status elasticsearch
#sudo systemctl stop elasticsearch
#sudo systemctl status elasticsearch
#sudo systemctl enable elasticsearch
#sudo systemctl start elasticsearch
#sudo systemctl status elasticsearch
# curl -X GET "localhost:9200/"

sudo apt install kibana
sudo systemctl daemon-reload
sudo echo 'server.port: 5601' > /etc/kibana/kibana.yml
sudo echo 'server.host: "0.0.0.0"' >> /etc/kibana/kibana.yml
sudo systemctl enable kibana
sudo systemctl start kibana
sudo systemctl status kibana
#curl http://localhost:5601
#sudo cat /etc/kibana/kibana.yml
#systemctl restart kibana
sudo systemctl restart kibana
#curl http://localhost:5601














# elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.10.2-amd64.deb
dpkg -i elasticsearch-*.deb
sed -i -e '$anetwork.host: 0.0.0.0' /etc/elasticsearch/elasticsearch.yml
sed -i -e '$adiscovery.type: single-node' /etc/elasticsearch/elasticsearch.yml
systemctl enable elasticsearch
systemctl start elasticsearch

# kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-oss-7.10.2-amd64.deb
dpkg -i kibana-*.deb
echo 'server.host: "0.0.0.0"' > /etc/kibana/kibana.yml
systemctl enable kibana
systemctl start kibana

echo "INFO: userdata finished"

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrQe20EN5U2aBkD0NEGBWPb9b4OeTof/yfsh/dLgdfwu2D7SGBxwGt4JLOiT0XgW4z2cuH5WUu4xe9e+jGDxYztP+zKtqSSYYE++1NREzA5aDgn8GX792+oxlkpeVddpUFPUK2qEXPsBHbJ5T5hNspqzeYhU6syxaJrIVd0CYu0SFiGrA2QDiMNPn/Q5z5IQSRsCarcBO8NKets47l9WKzCcBrL1xalOUcjz1rp5th25LsoBHpAZaGY1Ipm2iYhaXAx06sJDa+6jPnO/YZyEybldJAmrVZXCww2emtlV5VagzLae/T6GO+0dXTBruuksySzg7pgzdq8b3vhMutNq+rADaWtOMZZWM8FR4KYE8IVSMi6bv9Z63hivfhoPwh9+q1iePzQnmn922VdnzjL/t8ahU2udydwfGHXwLl75XEBnnWQSfZO9oMbxjfwR7KOMepESme4PBp1H4MB2feBUisX3Hd3PQ4111DyYUdAmZE96TaLJQEDGhOz0fIPZi7M+c= ubuntu@ip-10-0-4-214" > ~/ansible_key.pub
cat ~/ansible_key.pub >> ~/.ssh/authorized_keys

local_aws_hostname=$(curl http://169.254.169.254/latest/meta-data/local-hostname)


#wget -O ~/jenkins-cli.jar --no-check-certificate https://jenkins.galitu.site/jnlpJars/jenkins-cli.jar
#java -jar ~/jenkins-cli.jar -s https://jenkins.galitu.site/ -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -webSocket build Ansible_Consul_Install -s -v
#java -jar ~/jenkins-cli.jar -s https://jenkins.galitu.site/ -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -webSocket build Ansible_NodeExporter_Install -s -v
#java -jar ~/jenkins-cli.jar -s https://jenkins.galitu.site/ -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -webSocket build Ansible_filebeat_Install -s -v
