 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
echo -e "\n\n" $SCRIPT_DIR
rm "${SCRIPT_DIR}/FULL_CREATE_LOG.log"
{
    ./Only_vpc_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo "====> VPC created OK" || echo "====> Failed create VPC";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_keys_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo "====> KEYs were created OK" || echo "====> Failed creating KEYs";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_bastion_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo "====> Bastion host created and configured OK" || echo "====> Failed create Bastion host";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_kube_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo "====> KUBE created OK" || echo "====> Failed create KUBE";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_jenkins_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo "====> Jenkins environment created OK" || echo "====> Failed create Jenkins environment";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_consul_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo "====> Consul environment created OK" || echo "====> Failed create Consul environment";
    test $EXITCODE -ne 0 && exit $EXITCODE

    echo =================================================
    echo -e "\n\n" "====>>>>BUILD ENTIRE ENVIRONMENT FINISHED WITH SUCCESS"
} | tee "${SCRIPT_DIR}/FULL_CREATE_LOG.log"
