 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

# Create from vpc to end
cd $SCRIPT_DIR/..
MONITORING_CTL_PATH=$SCRIPT_DIR/../MONITORING
cd ./MONITORING
echo -e "\n\n" ==== Creates MONITORING for cluster environment ==== [basename $(pwd)]

#echo -e "\n\n" ==== Execute second time due to bug of Hashicorp - try create KUBERNETES cluster==== [basename $(pwd)]
cd ../KUBE

KUBE_CLUSTER_NAME=`terraform output kube_cluster_name`
cd $MONITORING_CTL_PATH

KUBE_CLUSTER_NAME_TRIM="${KUBE_CLUSTER_NAME%\"}"
KUBE_CLUSTER_NAME_TRIM="${KUBE_CLUSTER_NAME_TRIM#\"}"
echo -e "\n\n" K8S Cluster name = $KUBE_CLUSTER_NAME_TRIM

aws eks --region=eu-central-1 update-kubeconfig --name $KUBE_CLUSTER_NAME_TRIM

echo -e "\n\n" ==== Update latest versions of grafana and prometheus via HELM ==== [basename $(pwd)]
###  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
###  helm repo add grafana https://grafana.github.io/helm-charts
###  helm repo add hashicorp https://helm.releases.hashicorp.com
###  helm repo update
###  helm search repo hashicorp/consul

###  helm show values prometheus-community/kube-prometheus-stack > prometheus_original_values.yaml
###  helm show values grafana/grafana > grafana_original_values.yaml
###  helm show values hashicorp/consul > consul_original_values.yaml

echo -e "\n\n" ==== Install prometheus via HELM on EKS ==== [basename $(pwd)]
#kubectl create ns monitoring
#kubectl ns monitoring
####  helm install prometheus prometheus-community/prometheus \
####      --namespace monitoring --create-namespace \
####      --set alertmanager.persistentVolume.storageClass="gp2" \
####      --set server.persistentVolume.storageClass="gp2"
helm status prometheus --namespace monitoring
export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace monitoring port-forward $POD_NAME 9090 &
###kubectl port-forward -n monitoring deploy/prometheus-server 8080:9090 &
#prometheus-server.monitoring.svc.cluster.local

export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace monitoring port-forward $POD_NAME 9091 &
#prometheus-pushgateway.monitoring.svc.cluster.local

export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=alertmanager" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace monitoring port-forward $POD_NAME 9093 &
#prometheus-alertmanager.monitoring.svc.cluster.local

kubectl --namespace monitoring get pods -l "release=prometheus"

echo -e "\n\n" ==== Install grafana via HELM on EKS ==== [basename $(pwd)]
#kubectl create ns grafana
#kubectl ns grafana
#helm install grafana grafana/grafana -f grafana_values.yaml --namespace grafana
####   helm install grafana grafana/grafana \
####       --namespace grafana --create-namespace \
####       --set persistence.storageClassName="gp2" \
####       --set persistence.enabled=true \
####       --set adminPassword='Galitu' \
####       --values grafana_values.yaml
helm status grafana --namespace grafana

GRAFANA_PASSWORD=`kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode`
echo Grafana password [$GRAFANA_PASSWORD]
#grafana.grafana.svc.cluster.local
export POD_NAME=$(kubectl get pods --namespace grafana -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace grafana port-forward $POD_NAME 3000 &

echo -e "\n\n" ==== Install consul via HELM on EKS ==== [basename $(pwd)]
### kubectl create ns consul
kubectl ns consul
### kubectl create secret generic consul-gossip-encryption-key --from-literal=key="uDBV4e+LbFW3019YKPxIrg=="
#### helm install consul hashicorp/consul -f consul_values.yaml
helm status consul --namespace consul
#helm get all consul --namespace consul

# Set core-dns with consul
####   echo ==== Before change of coredns config map file ====
####   kubectl get cm coredns -n kube-system -o yaml
####   export CONSUL_DNS_IP=`kubectl get svc consul-consul-dns -n consul --output jsonpath='{.spec.####   clusterIP}'`
####   echo Consul service appears at address = $CONSUL_DNS_IP
####   envsubst < $MONITORING_CTL_PATH/core_dns_config_map.tmpl > $MONITORING_CTL_PATH/core_dns_config_map.####   yaml
####   kubectl apply -f $MONITORING_CTL_PATH/core_dns_config_map.yaml
echo ==== After change of coredns config map file ====
kubectl get cm coredns -n kube-system -o yaml
