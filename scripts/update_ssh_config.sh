 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

MID_PRJ_DIR_PATH=`dirname $path`
echo $MID_PRJ_DIR_PATH

# Execute update bastion server

cd $MID_PRJ_DIR_PATH/../bastion_standalone
#terraform apply -auto-approve
#exit 0

echo y | ssh-config add "Bastion_host" HostName=3.70.100.240 -b IdentityFile="~/.ssh/SSH_KEYS_FOR_Amazon/Key_Bastion_Kandula_MPrj.pem" StrictHostKeyChecking=no User=ubuntu ForwardAgent=yes UserKnownHostsFile=/dev/null Port=22

echo y | ssh-config add "10.0.1.*" IdentityFile="~/.ssh/SSH_KEYS_FOR_Amazon/Key_Consul_Kandula_MPrj.pem"

echo y |  ssh-config add "10.0.2.*" IdentityFile="~/.ssh/SSH_KEYS_FOR_Amazon/Key_Consul_Kandula_MPrj.pem"

echo y | ssh-config add "10.0.3.*" IdentityFile="~/.ssh/SSH_KEYS_FOR_Amazon/Key_Master_Kandula_MPrj.pem"

echo y |  ssh-config add "10.0.4.*" IdentityFile="~/.ssh/SSH_KEYS_FOR_Amazon/Key_Master_Kandula_MPrj.pem"

echo y | ssh-config add "10.0.5.*" IdentityFile="~/.ssh/SSH_KEYS_FOR_Amazon/Key_WebServers_Kandula_MPrj.pem"

echo y | ssh-config add "10.0.6.*" IdentityFile="~/.ssh/SSH_KEYS_FOR_Amazon/Key_WebServers_Kandula_MPrj.pem"

echo y | ssh-config add "10.0.31.*" IdentityFile="~/.ssh/SSH_KEYS_FOR_Amazon/Key_Bastion_Kandula_MPrj.pem" StrictHostKeyChecking=no User=ubuntu ForwardAgent=yes UserKnownHostsFile=/dev/null Port=22

for i in {0..6}
  do
     echo y | ssh-config update -p  "10.0.$i.*" StrictHostKeyChecking=no
     echo y | ssh-config update -p  "10.0.$i.*" User=ubuntu
     echo y | ssh-config update -p  "10.0.$i.*" ForwardAgent=yes
     echo y | ssh-config update -p  "10.0.$i.*" Port=22
     echo y | ssh-config update -p  "10.0.$i.*" ProxyJump=Bastion_host
     echo y | ssh-config update -p  "10.0.$i.*" UserKnownHostsFile=/dev/null
 done
