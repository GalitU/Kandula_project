 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

MID_PRJ_DIR_PATH=`dirname $path`
echo $MID_PRJ_DIR_PATH

# Execute update bastion server
cd $MID_PRJ_DIR_PATH/../bastion_standalone
echo terraform destroy from [$MID_PRJ_DIR_PATH/../bastion_standalone]
terraform destroy

# Create ann vpc and more
cd $MID_PRJ_DIR_PATH/../FULL_ENV
echo terraform destroy from [$MID_PRJ_DIR_PATH/../FULL_ENV]
terraform destroy -auto-approve
