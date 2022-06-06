echo on
pushd C:\Data\OpsSchool\MidProject\KANDULA_DEPLOYMENT
minikube start
kubectl get nodes
kubectl apply -f pod_kandula_secrets.yaml
kubectl apply -f deploy-kandula.yaml
kubectl get deployments
kubectl get deploy -o wide
kubectl expose deployment deployment-kandula-app --name=my-kandula --type=NodePort --port=5000
kubectl get svc my-kandula
minikube service my-kandula --url
