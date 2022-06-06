 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

# Create from vpc to end
cd $SCRIPT_DIR/..

cd ./KUBE
echo -e "\n\n" ==== Creates KUBERNETES cluster==== [basename $(pwd)]
terraform apply -auto-approve
echo -e "\n\n" ==== Execute second time due to bug of Hashicorp - try create KUBERNETES cluster==== [basename $(pwd)]
terraform apply -auto-approve
KUBE_CLUSTER_NAME=`terraform output kube_cluster_name`
KUBE_CLUSTER_NAME_TRIM="${KUBE_CLUSTER_NAME%\"}"
KUBE_CLUSTER_NAME_TRIM="${KUBE_CLUSTER_NAME_TRIM#\"}"
echo -e "\n\n" K8S Cluster name = $KUBE_CLUSTER_NAME_TRIM
cd ..

KUBERNETIS_CTL_PATH=$SCRIPT_DIR/../../KANDULA_DEPLOYMENT
cd $KUBERNETIS_CTL_PATH
echo -e "\n\n" ==== Start Kandula on EKS ==== [basename $(pwd)]

aws eks --region=eu-central-1 update-kubeconfig --name $KUBE_CLUSTER_NAME_TRIM
kubectl get nodes -o wide
kubectl apply -f $KUBERNETIS_CTL_PATH/pod_kandula_secrets.yaml
kubectl create -f $KUBERNETIS_CTL_PATH/pod-svc-deploy-kandula-LB.yaml
kubectl create -f $KUBERNETIS_CTL_PATH/deploy-kandula.yaml

kubectl logs kandula-pod
pod_1=`kubectl get pods | awk 'FNR == 2 {print $1}'`
pod_2=`kubectl get pods | awk 'FNR == 3 {print $1}'`
kubectl logs $pod_1
kubectl logs $pod_2

kubectl get secrets
echo -e "\n\n" ===== Kube Services are =================
kubectl get svc --show-labels

echo -e "\n\n" ===== Kube Pods are =================
kubectl get pods --show-labels

echo -e "\n\n" ===== Kube Events are =================
kubectl get events

echo -e "\n\n" ===== Kube Deployments are =================
kubectl get deployments --show-labels

echo -e "\n\n" ===== Kube Pods are =================
echo $pod_1
echo $pod_2
echo =================================================
echo -e "\n\n" "BUILD KUBE FINISHED"
