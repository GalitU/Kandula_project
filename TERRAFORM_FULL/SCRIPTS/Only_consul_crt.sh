 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

# Create from vpc to end
cd $SCRIPT_DIR/..


cd ./CONSUL
echo -e "\n\n" ==== Creates Consul servers ==== [basename $(pwd)]
#### terraform init
terraform apply -auto-approve
EXITCODE=$?
test $EXITCODE -ne 0 && exit $EXITCODE

cd ..
# read -p "Press any key to continue...    " -n1 -s


#####  ANSIBLE_CONSUL_PATH=$SCRIPT_DIR/../../ansible
#####  cd $ANSIBLE_CONSUL_PATH
#####  echo -e "\n\n"==== Install Consul server and agent on all relevant instaces ==== [basename $(pwd)]
#####  ansible all -i $ANSIBLE_CONSUL_PATH/aws_ec2.yaml -m ping
#####  
#####  echo -e "\n\n" ==== Install Consul on all EC2 servers ==== [basename $(pwd)]
#####  ansible-playbook -i $ANSIBLE_CONSUL_PATH/aws_ec2.yaml $ANSIBLE_CONSUL_PATH/consul_install.yml
#####  
#####  echo -e "\n\n" ==== Install Node_exporter on all EC2 servers ==== [basename $(pwd)]
#####  ansible-playbook -i $ANSIBLE_CONSUL_PATH/aws_ec2.yaml $ANSIBLE_CONSUL_PATH/node_exporter_install.yml

# read -p "Press any key to continue...    " -n1 -s

echo =================================================
echo -e "\n\n" "BUILD CONSUL FINISHED"
