 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

# Create from vpc to end
cd $SCRIPT_DIR/..


cd ./BASTION

echo -e "\n\n" ==== Creates Bastion ==== [basename $(pwd)]
terraform apply -auto-approve

python3 update_config_ssh_file.py
chmod 644 ./config
cp ./config ~/.ssh/config

##########  BASTION_PUB_IP=`terraform output bastion_server_public_ip`
##########  BASTION_PUB_IP_TRIM="${BASTION_PUB_IP%\"}"
##########  BASTION_PUB_IP_TRIM="${BASTION_PUB_IP_TRIM#\"}"
##########  echo -e "\n\n" Bastion public IP = $BASTION_PUB_IP_TRIM
##########
##########  CURR_BASTION_IP=`ssh-config get Bastion_host | grep -oP $BASTION_PUB_IP_TRIM`
##########
##########  if [[ "$CURR_BASTION_IP" != "$BASTION_PUB_IP_TRIM" ]]; then
##########      echo y | ssh-config update -p "Bastion_host" HostName=$BASTION_PUB_IP_TRIM StrictHostKeyChecking=no User=ubuntu ForwardAgent=yes UserKnownHostsFile=/dev/null Port=22
##########      sleep 1
##########      for i in {1..7}
##########      do
##########          echo y | ssh-config update -p  "10.0.$i.*" StrictHostKeyChecking=no User=ubuntu ForwardAgent=yes Port=22 Port=22 UserKnownHostsFile=/dev/null ProxyJump=Bastion_host
##########          sleep 1
##########      done
##########  else
##########      echo "Info : Bastion IP is the same, will be not changed"
##########  fi
cd ..

# read -p "Press any key to continue...    " -n1 -s

echo =================================================
echo -e "\n\n" "BUILD BASTION FINISHED"
