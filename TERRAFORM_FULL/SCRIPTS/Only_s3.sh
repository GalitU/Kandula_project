 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

cd $SCRIPT_DIR/..
cd ./S3_BUCKET
echo -e "\n\n" ==== Creates S3 ==== [basename $(pwd)]
terraform apply -auto-approve
cd ..
# read -p "Press any key to continue...    " -n1 -s

echo =================================================
echo -e "\n\n" "BUILD S3 FINISHED"
