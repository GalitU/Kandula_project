 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

# Create from vpc to end
cd $SCRIPT_DIR/..

cd ./KUBE_KANDULA_APP
echo -e "\n\n" ==== Creates KUBERNETES Kandula application in the cluster ==== [basename $(pwd)]
#### terraform init
terraform apply -auto-approve
EXITCODE=$?
test $EXITCODE -ne 0 && exit $EXITCODE

#echo -e "\n\n" ==== Execute second time due to bug of Hashicorp - try create KUBERNETES cluster==== [basename $(pwd)]
KUBE_CLUSTER_NAME=`terraform output kube_cluster_name`
KUBE_CLUSTER_NAME_TRIM="${KUBE_CLUSTER_NAME%\"}"
KUBE_CLUSTER_NAME_TRIM="${KUBE_CLUSTER_NAME_TRIM#\"}"
echo -e "\n\n" K8S Cluster name = $KUBE_CLUSTER_NAME_TRIM
cd ..
aws eks --region=eu-central-1 update-kubeconfig --name $KUBE_CLUSTER_NAME_TRIM

KUBERNETIS_CTL_PATH=$SCRIPT_DIR/../../KANDULA_DEPLOYMENT
cd $KUBERNETIS_CTL_PATH
echo -e "\n\n" ==== Start Kandula on EKS ==== [basename $(pwd)]

kubectl get nodes -o wide --show-labels -n kandula
EXITCODE=$?
test $EXITCODE -ne 0 && exit $EXITCODE

######  #Secrets
######  kubectl apply -f $KUBERNETIS_CTL_PATH/kandula_secret.yaml
######  EXITCODE=$?
######  test $EXITCODE -ne 0 && exit $EXITCODE

######   # Apply Kandula including ingress Ingress with deployment
######   kubectl apply -f  $KUBERNETIS_CTL_PATH/kandula_on_kube.yaml
######   EXITCODE=$?
######   test $EXITCODE -ne 0 && exit $EXITCODE

# Apply Kandula including ingress Ingress with deployment
####kubectl apply -f  $KUBERNETIS_CTL_PATH/kandula_ingress.yaml
####EXITCODE=$?
####test $EXITCODE -ne 0 && exit $EXITCODE


pod_1=`kubectl get pods --show-labels -n kandula| awk 'FNR == 2 {print $1}'`
pod_2=`kubectl get pods --show-labels -n kandula| awk 'FNR == 3 {print $1}'`
kubectl logs $pod_1 -n kandula
EXITCODE=$?
test $EXITCODE -ne 0 && exit $EXITCODE

kubectl logs $pod_2 -n kandula
EXITCODE=$?
test $EXITCODE -ne 0 && exit $EXITCODE

kubectl get secrets --show-labels -n kandula
EXITCODE=$?
test $EXITCODE -ne 0 && exit $EXITCODE

echo -e "\n\n" ===== Kube Services are =================
kubectl get svc --show-labels -n kandula
EXITCODE=$?
test $EXITCODE -ne 0 && exit $EXITCODE

echo -e "\n\n" ===== Kube Pods are =================
kubectl get pods --show-labels  -n kandula
EXITCODE=$?
test $EXITCODE -ne 0 && exit $EXITCODE

echo -e "\n\n" ===== Kube Events are =================
kubectl get events --show-labels -n kandula
EXITCODE=$?
test $EXITCODE -ne 0 && exit $EXITCODE

echo -e "\n\n" ===== Kube Deployments are =================
kubectl get deployments --show-labels -n kandula
EXITCODE=$?
test $EXITCODE -ne 0 && exit $EXITCODE

echo -e "\n\n" ===== Kube Ingress are =================
kubectl get ingress --show-labels -n kandula
EXITCODE=$?
test $EXITCODE -ne 0 && exit $EXITCODE

echo -e "\n\n" ===== Kube Pods are =================
echo $pod_1
echo $pod_2

echo =================================================
echo -e "\n\n" "BUILD KUBE APPLICATION FINISHED"
echo -e "\n\n" "https://kandula.galitu.site is ready"
