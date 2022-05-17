 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
#echo -e "\n\n" $SCRIPT_DIR

cd ./TERRAFORM_FULL/SCRIPTS/
echo -e "\n\n" "==== From here what will be done... ===="


echo -e "\n\n" "WARNING : THIS SCRIPT WILL DESTROY ALL YOUR ENVIRONMENT"
echo "Are you sure you want to proceed ?"
read -p "Press ENTER for continue, othervise [CTRL + C] . . . . . ." -n1 -s

./destroy_full_evironment.sh

echo "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
echo "|    Congratulations : You can go and look for your Kandula "
echo "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
