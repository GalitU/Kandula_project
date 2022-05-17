 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR

# Create from vpc to end
cd $SCRIPT_DIR/..

rm "${SCRIPT_DIR}/FULL_DESTROY_LOG.log"
{
    echo -e "\n\n" ==== Delete Kandula application and all relevant parts ====
    kubectl delete pod kandula-pod
    kubectl delete secret kandula-secrets
    kubectl delete svc kandula-load-balancer
    kubectl delete deployment deployment-kandula-app
    kubectl delete svc kandula-deploy-load-balancer
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo "====> Stop Kandula finished OK" || echo "====> Failed stop Kandula";
    #test $EXITCODE -ne 0 && exit $EXITCODE

    cd ./KUBE
    echo -e "\n\n" ==== Destroy KUBERNETES ==== [basename $(pwd)]
    echo yes | terraform destroy
    cd ..
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo "====> Destroy KUBE finished OK" || echo "====> Failed destroy KUBE";
    test $EXITCODE -ne 0 && exit $EXITCODE
    #read -p "Press any key to continue...    " -n1 -s

    cd ./CONSUL
    echo -e "\n\n" ==== Destroy Consul servers ==== [basename $(pwd)]
    echo yes | terraform destroy
    cd ..
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo "====> Destroy CONSUL finished OK" || echo "====> Failed destroy CONSUL";
    test $EXITCODE -ne 0 && exit $EXITCODE
    #read -p "Press any key to continue...    " -n1 -s

    cd ./JENKINS

    echo ==== Delete Jenkins nodes at Jenkins server ====
    python delete_jenkins_node.py.py

    echo -e "\n\n" ==== Destroy Jenkins ==== [basename $(pwd)]
    echo yes | terraform destroy
    cd ..
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo "====> Destroy JENKINS environment finished OK" || echo "====> Failed destroy JENKINS environment";
    test $EXITCODE -ne 0 && exit $EXITCODE
    #read -p "Press any key to continue...    " -n1 -s

    cd ./BASTION
    echo -e "\n\n" ==== Destroy Bastion ==== [basename $(pwd)]
    echo yes | terraform destroy
    cd ..
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo "====> Destroy BASTION environment finished OK" || echo "====> Failed destroy BASTION environment";
    test $EXITCODE -ne 0 && exit $EXITCODE
    #read -p "Press any key to continue...    " -n1 -s

    cd ./KEYS
    echo -e "\n\n" ==== Destroy KEYS ==== [basename $(pwd)]
    echo yes | terraform destroy
    cd ..
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo "====> Destroy KEYS environment finished OK" || echo "====> Failed destroy KEYS environment";
    test $EXITCODE -ne 0 && exit $EXITCODE
    #read -p "Press any key to continue...    " -n1 -s

    cd ./VPC
    echo -e "\n\n" ==== Destroy VPC ==== [basename $(pwd)]
    echo yes | terraform destroy
    cd ..
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo "====> Destroy VPC environment finished OK" || echo "====> Failed destroy VPC environment";
    test $EXITCODE -ne 0 && exit $EXITCODE
    #read -p "Press any key to continue...    " -n1 -s

    echo =================================================
    echo -e "\n\n" "====>>>>  DESTROY ENTIRE ENVIRONMENT FINISHED WITH SUCCESS"
} | tee "${SCRIPT_DIR}/FULL_DESTROY_LOG.log"
