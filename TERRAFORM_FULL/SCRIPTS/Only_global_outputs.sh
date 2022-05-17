 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
cd $SCRIPT_DIR/..

echo -e "\n\n"=========================================================================
cd ./CONSUL
echo -e "\n\n" "CONSUL UI = [http://`terraform output -raw cosul_alb_dns `]"

cd ..

cd ./JENKINS
echo -e "\n\n" "CONSUL UI = [http://`terraform output -raw jenkins_alb_dns `]"

aws eks --region=eu-central-1  update-kubeconfig --name kandula-mid-kube > out.log 2> err.log

echo -e "\n\n" "KANDULA started at [http://`kubectl get svc | awk 'FNR == 2 {print $4}'`]"
echo -e "\n\n"=========================================================================
