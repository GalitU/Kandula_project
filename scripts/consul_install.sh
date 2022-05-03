 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

MID_PRJ_DIR_PATH=`dirname $path`
echo $MID_PRJ_DIR_PATH

# Execute update bastion server
cd $MID_PRJ_DIR_PATH/../bastion_standalone
terraform apply -auto-approve

# Copy all keys to relevant ~/.ssh directory
cp $MID_PRJ_DIR_PATH/../FULL_ENV/Key*.pem ~/.ssh/SSH_KEYS_FOR_Amazon/ -f
chmod 400 ~/.ssh/SSH_KEYS_FOR_Amazon/*.pem
ls -l ~/.ssh/SSH_KEYS_FOR_Amazon/Key*.pem
echo "Result : all ../FULL_ENV/Key*.pem was copied to ~/.ssh/SSH_KEYS_FOR_Amazon/*.pem"

echo "Start execute ansible scripts"
cd $MID_PRJ_DIR_PATH/../ansible/roles
echo $MID_PRJ_DIR_PATH/../ansible/roles

#ansible-inventory -i $MID_PRJ_DIR_PATH/../ansible/roles/aws_ec2.yaml --list
#ansible all -i $MID_PRJ_DIR_PATH/../ansible/roles/aws_ec2.yaml -m ping
#ansible-playbook -i $MID_PRJ_DIR_PATH/../ansible/roles/aws_ec2.yaml $MID_PRJ_DIR_PATH/../ansible/roles/file_test_bastion.yml

#-----------------------------------------------------

#ansible-inventory -i $MID_PRJ_DIR_PATH/../ansible/roles/aws_ec2.yaml --list
ansible all -i $MID_PRJ_DIR_PATH/../ansible/roles/aws_ec2.yaml -m ping
ansible-playbook -i $MID_PRJ_DIR_PATH/../ansible/roles/aws_ec2.yaml $MID_PRJ_DIR_PATH/../ansible/roles/consul_install.yml
