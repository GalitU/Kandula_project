 #!/bin/bash

###    ### Start NGINX Ingress controller
###    ###kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.2.0/deploy/static/provider/aws    ######deploy.yaml
###    ##sleep 5
###    ##kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
###    ##
###    ### Start Kandula under Ingress controller
###    ##kubectl apply -f kandula_secrets.yaml
###    ##kubectl apply -f kandula_deploy.yaml
###    ##kubectl apply -f kandula_cluster_ip.yaml
###    ##kubectl apply -f kandula_on_kube.yaml
###    ##
###    ##LB_KUBE=`kubectl get ingress -n kandula | awk 'FNR == 2 {print $4}'`
###    ##echo $LB_KUBE
###    ##python ./update_route_record.py -l $LB_KUBE -n kandula -z Z02370232BHPFBL1PV6YN -s galitu.site
###    ##
###    ##kubectl get --all-namespaces all -o wide
###    ##kubectl get all -n kandula -o wide
###    ##kubectl get ingress -n kandula -o wide
###    ##kubectl describe ingress -n kandula


##### Start ALB Amazon Ingress
aws eks --region=eu-central-1 update-kubeconfig --name kandula-prj-kube

kubectl apply -f kandula_on_kube.yaml

LB_KUBE=`kubectl get ingress -n kandula | awk 'FNR == 2 {print $4}'`
echo $LB_KUBE
python3 ./update_route_record.py -l $LB_KUBE -n kandula -z Z02370232BHPFBL1PV6YN -s galitu.site
###    ##
kubectl get --all-namespaces all -o wide
kubectl get all -n kandula -o wide
kubectl get ingress -n kandula -o wide
kubectl describe ingress -n kandula

echo -e "\n\n" "You can start your Kandula at https://kandula.galitu.site"
