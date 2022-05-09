 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

# Create from vpc to end
cd $SCRIPT_DIR/..

cd ./JENKINS
echo -e "\n\n" ==== Creates Jenkins ==== [basename $(pwd)]
terraform apply -auto-approve
cd ..
# read -p "Press any key to continue...    " -n1 -s


echo =================================================
echo -e "\n\n" "BUILD JENKINS FINISHED"
