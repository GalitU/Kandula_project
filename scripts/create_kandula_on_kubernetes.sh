#!/bin/bash
path=`readlink -f "${BASH_SOURCE:-$0}"`

MID_PRJ_DIR_PATH=`dirname $path`
echo $MID_PRJ_DIR_PATH

aws eks --region=eu-central-1 update-kubeconfig --name kandula-mid-kube-1LJcwmcF
kubectl get nodes -o wide

kubectl create -f $MID_PRJ_DIR_PATH/../FULL_ENV/../kubernetes/pod_kandula_secrets.yaml
kubectl create -f $MID_PRJ_DIR_PATH/../FULL_ENV/../kubernetes/pod-svc-kandula_LB.yaml
kubectl create -f $MID_PRJ_DIR_PATH/../FULL_ENV/../kubernetes/pod-kandula.yaml
kubectl get svc
kubectl get pods
kubectl get events
kubectl logs kandula-pod
