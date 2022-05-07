 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo $SCRIPT_DIR

# Create ann vpc and more
cd $SCRIPT_DIR/../FULL_ENV
terraform apply -auto-approve

# Execute update bastion server
cd $SCRIPT_DIR/../bastion_standalone
terraform apply -auto-approve


sh $SCRIPT_DIR/handle_pem_file.sh
