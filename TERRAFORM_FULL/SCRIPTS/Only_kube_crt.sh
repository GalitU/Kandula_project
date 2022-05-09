 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

# Create from vpc to end
cd $SCRIPT_DIR/..

cd ./KUBE
echo -e "\n\n" ==== Creates KUBERNETES cluster==== [basename $(pwd)]
terraform apply -auto-approve
KUBE_CLUSTER_NAME=`terraform output kube_cluster_name`
KUBE_CLUSTER_NAME_TRIM="${KUBE_CLUSTER_NAME%\"}"
KUBE_CLUSTER_NAME_TRIM="${KUBE_CLUSTER_NAME_TRIM#\"}"
echo -e "\n\n" K8S Cluster name = $KUBE_CLUSTER_NAME_TRIM
cd ..

KUBERNETIS_CTL_PATH=$SCRIPT_DIR/../../kubernetes
cd $KUBERNETIS_CTL_PATH
echo -e "\n\n" ==== Start Kandula on EKS ==== [basename $(pwd)]

aws eks --region=eu-central-1 update-kubeconfig --name $KUBE_CLUSTER_NAME_TRIM
kubectl get nodes -o wide
kubectl apply -f $KUBERNETIS_CTL_PATH/pod_kandula_secrets.yaml
kubectl create -f $KUBERNETIS_CTL_PATH/pod-svc-kandula_LB.yaml
kubectl create -f $KUBERNETIS_CTL_PATH/pod-kandula.yaml

kubectl get secrets
kubectl get svc
kubectl get pods
kubectl get events
kubectl logs kandula-pod

echo =================================================
echo -e "\n\n" "BUILD KUBE FINISHED"
