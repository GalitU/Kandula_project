 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

cd $SCRIPT_DIR/..
cd ./KEYS
echo -e "\n\n" ==== Creates KEYS ==== [basename $(pwd)]
terraform apply -auto-approve
echo -e "\n\n" -- Copy Keys to ~/.ssh
cp ./Key*.pem ~/.ssh/SSH_KEYS_FOR_Amazon/ -f
chmod 400 ~/.ssh/SSH_KEYS_FOR_Amazon/*.pem
ls -l ~/.ssh/SSH_KEYS_FOR_Amazon/Key*.pem
cd ..
# read -p "Press any key to continue...    " -n1 -s

echo =================================================
echo -e "\n\n" "BUILD KEYS FINISHED"
