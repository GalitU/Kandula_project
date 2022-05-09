 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

./Only_vpc_crt.sh
./Only_keys_crt.sh
./Only_bastion_crt.sh
./Only_consul_crt.sh
./Only_jenkins_crt.sh
./Only_kube_crt.sh

echo =================================================
echo -e "\n\n" "BUILD ENTIRE FINISHED"
