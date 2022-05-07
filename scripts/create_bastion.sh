 #!/bin/bash

path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo $SCRIPT_DIR

# Execute update bastion server
cd $SCRIPT_DIR/../bastion_standalone
terraform apply -auto-approve
