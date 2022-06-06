 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

# Create from vpc to end
cd $SCRIPT_DIR/..

cd ./JENKINS
echo -e "\n\n" ==== Creates Jenkins ==== [basename $(pwd)]
terraform apply -auto-approve

echo ==== Update Jenkins nodes at Jenkins server ====
python3 add_jenkins_node.py

cd ..
# read -p "Press any key to continue...    " -n1 -s


echo =================================================
echo -e "\n\n" "BUILD JENKINS FINISHED"
