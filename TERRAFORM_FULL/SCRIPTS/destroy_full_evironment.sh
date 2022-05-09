 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

# Create from vpc to end
cd $SCRIPT_DIR/..

echo -e "\n\n" ==== Delete Kandula application and all relevant parts ====
kubectl delete pod kandula-pod
kubectl delete svc kandula-load-balancer
kubectl delete secret kandula-secrets

cd ./KUBE
echo -e "\n\n" ==== Destroy KUBERNETES ==== [basename $(pwd)]
terraform destroy
cd ..
read -p "Press any key to continue...    " -n1 -s

cd ./CONSUL
echo -e "\n\n" ==== Destroy Consul servers ==== [basename $(pwd)]
terraform destroy
cd ..
read -p "Press any key to continue...    " -n1 -s

cd ./JENKINS
echo -e "\n\n" ==== Destroy Jenkins ==== [basename $(pwd)]
terraform destroy
cd ..
read -p "Press any key to continue...    " -n1 -s

cd ./BASTION
echo -e "\n\n" ==== Destroy Bastion ==== [basename $(pwd)]
terraform destroy
cd ..
read -p "Press any key to continue...    " -n1 -s

cd ./KEYS
echo -e "\n\n" ==== Destroy KEYS ==== [basename $(pwd)]
terraform destroy
cd ..
read -p "Press any key to continue...    " -n1 -s

cd ./VPC
echo -e "\n\n" ==== Destroy VPC ==== [basename $(pwd)]
terraform destroy
cd ..
read -p "Press any key to continue...    " -n1 -s

echo =================================================
echo -e "\n\n" "Destroy env FINISHED"
