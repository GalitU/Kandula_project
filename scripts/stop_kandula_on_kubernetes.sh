#!/bin/bash
path=`readlink -f "${BASH_SOURCE:-$0}"`

MID_PRJ_DIR_PATH=`dirname $path`
echo $MID_PRJ_DIR_PATH

kubectl delete pod kandula-pod
kubectl delete svc kandula-load-balancer
kubectl delete secret kandula-secrets
