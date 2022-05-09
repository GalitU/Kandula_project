 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

MID_PRJ_DIR_PATH=`dirname $path`
echo $MID_PRJ_DIR_PATH

# Create ann vpc and more
cd $MID_PRJ_DIR_PATH/../FULL_ENV
cd $MID_PRJ_DIR_PATH/../TERRAFORM_FULL/KEYS
pwd
# Copy all keys to relevant ~/.ssh directory
cp ./Key*.pem ~/.ssh/SSH_KEYS_FOR_Amazon/ -f
chmod 400 ~/.ssh/SSH_KEYS_FOR_Amazon/*.pem
ls -l ~/.ssh/SSH_KEYS_FOR_Amazon/Key*.pem
echo "Result : all ../FULL_ENV/Key*.pem was copied to ~/.ssh/SSH_KEYS_FOR_Amazon/*.pem"

echo "==========================================================="
echo "Now you can call ${MID_PRJ_DIR_PATH}/consul_install.sh"
echo "==========================================================="
