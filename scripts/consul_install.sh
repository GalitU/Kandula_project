#!/bin/bash

path=`readlink -f "${BASH_SOURCE:-$0}"`

MID_PRJ_DIR_PATH=`dirname $path`
echo $MID_PRJ_DIR_PATH

echo "Start execute ansible scripts"
cd $MID_PRJ_DIR_PATH/../ansible/consul
echo $MID_PRJ_DIR_PATH/../ansible/consul

#ansible-inventory -i $MID_PRJ_DIR_PATH/../ansible/consul/aws_ec2.yaml --list
#ansible all -i $MID_PRJ_DIR_PATH/../ansible/consul/aws_ec2.yaml -m ping
#ansible-playbook -i $MID_PRJ_DIR_PATH/../ansible/consul/aws_ec2.yaml $MID_PRJ_DIR_PATH/../ansible/roles/file_test_bastion.yml

#-----------------------------------------------------

#ansible-inventory -i $MID_PRJ_DIR_PATH/../ansible/roles/aws_ec2.yaml --list
ansible all -i $MID_PRJ_DIR_PATH/../ansible/consul/aws_ec2.yaml -m ping
ansible-playbook -i $MID_PRJ_DIR_PATH/../ansible/consul/aws_ec2.yaml $MID_PRJ_DIR_PATH/../ansible/consul/consul_install.yml
