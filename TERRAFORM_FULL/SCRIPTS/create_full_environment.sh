 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

# Create from vpc to end
cd $SCRIPT_DIR/..

cd ./VPC
echo -e "\n\n" ==== Creates VPC ==== [basename $(pwd)]
terraform apply -auto-approve
cd ..
# read -p "Press any key to continue...    " -n1 -s

cd ./KEYS
echo -e "\n\n" ==== Creates KEYS ==== [basename $(pwd)]
terraform apply -auto-approve
echo -e "\n\n" -- Copy Keys to ~/.ssh
cp ./Key*.pem ~/.ssh/SSH_KEYS_FOR_Amazon/ -f
chmod 400 ~/.ssh/SSH_KEYS_FOR_Amazon/*.pem
ls -l ~/.ssh/SSH_KEYS_FOR_Amazon/Key*.pem
cd ..
# read -p "Press any key to continue...    " -n1 -s


cd ./BASTION
echo -e "\n\n" ==== Creates Bastion ==== [basename $(pwd)]
terraform apply -auto-approve
BASTION_PUB_IP=`terraform output bastion_server_public_ip`
BASTION_PUB_IP_TRIM="${BASTION_PUB_IP%\"}"
BASTION_PUB_IP_TRIM="${BASTION_PUB_IP_TRIM#\"}"
echo -e "\n\n" Bastion public IP = $BASTION_PUB_IP_TRIM

CURR_BASTION_IP=`ssh-config get Bastion_host | grep -oP $BASTION_PUB_IP_TRIM`

if [[ "$CURR_BASTION_IP" != "$BASTION_PUB_IP_TRIM" ]]; then
    echo y | ssh-config update -p "Bastion_host" HostName=$BASTION_PUB_IP_TRIM StrictHostKeyChecking=no User=ubuntu ForwardAgent=yes UserKnownHostsFile=/dev/null Port=22
    sleep 1
    for i in {1..7}
    do
        echo y | ssh-config update -p  "10.0.$i.*" StrictHostKeyChecking=no User=ubuntu ForwardAgent=yes Port=22 Port=22 UserKnownHostsFile=/dev/null ProxyJump=Bastion_host
        sleep 1
    done
else
    echo "Info : Bastion IP is the same, will be not changed"
fi
cd ..

# read -p "Press any key to continue...    " -n1 -s

cd ./JENKINS
echo -e "\n\n" ==== Creates Jenkins ==== [basename $(pwd)]
terraform apply -auto-approve

echo ==== Update Jenkins nodes at Jenkins server ====
python add_jenkins_node.py

cd ..
# read -p "Press any key to continue...    " -n1 -s

cd ./CONSUL
echo -e "\n\n" ==== Creates Consul servers ==== [basename $(pwd)]
terraform apply -auto-approve
cd ..
# read -p "Press any key to continue...    " -n1 -s


ANSIBLE_CONSUL_PATH=$SCRIPT_DIR/../../ansible/consul
cd $ANSIBLE_CONSUL_PATH
echo -e "\n\n"==== Install Consul server and agent on all relevant instaces ==== [basename $(pwd)]
ansible all -i $ANSIBLE_CONSUL_PATHl/aws_ec2.yaml -m ping
ansible-playbook -i $ANSIBLE_CONSUL_PATH/aws_ec2.yaml $ANSIBLE_CONSUL_PATH/consul_install.yml
# read -p "Press any key to continue...    " -n1 -s

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
echo -e "\n\n" "BUILD env. FINISHED"
