 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

# Create from vpc to end
cd $SCRIPT_DIR/..

cd ./KUBE
echo -e "\n\n" ==== Creates KUBERNETES cluster==== [basename $(pwd)]
#### terraform init
terraform apply -auto-approve
EXITCODE=$?
test $EXITCODE -ne 0 && exit $EXITCODE

#echo -e "\n\n" ==== Execute second time due to bug of Hashicorp - try create KUBERNETES cluster==== [basename $(pwd)]
#terraform apply -auto-approve
#####   KUBE_CLUSTER_NAME=`terraform output kube_cluster_name`
#####   KUBE_CLUSTER_NAME_TRIM="${KUBE_CLUSTER_NAME%\"}"
#####   KUBE_CLUSTER_NAME_TRIM="${KUBE_CLUSTER_NAME_TRIM#\"}"
#####   echo -e "\n\n" K8S Cluster name = $KUBE_CLUSTER_NAME_TRIM
#####   cd ..
#####   aws eks --region=eu-central-1 update-kubeconfig --name $KUBE_CLUSTER_NAME_TRIM

echo =================================================
echo -e "\n\n" "BUILD KUBE FINISHED"
