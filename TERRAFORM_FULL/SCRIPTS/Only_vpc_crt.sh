 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

# Create from vpc to end
cd $SCRIPT_DIR/..

cd ./VPC
echo -e "\n\n" ==== Creates VPC ==== [basename $(pwd)]
#### terraform init
terraform apply -auto-approve
EXITCODE=$?
test $EXITCODE -ne 0 && exit $EXITCODE

cd ..
# read -p "Press any key to continue...    " -n1 -s

echo =================================================
echo -e "\n\n" "BUILD VPC FINISHED"
