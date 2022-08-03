 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
#echo -e "\n\n" $SCRIPT_DIR
rm "${SCRIPT_DIR}/../../FULL_CREATE_LOG.log"
{
    ./Only_s3.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> S3 created OK" || echo "====> Failed create VPC";
    test $EXITCODE -ne 0 && exit $EXITCODE

    #./Only_full_env.sh
    #EXITCODE=$?
    #test $EXITCODE -eq 0 && echo -e "\n" "====> Full env created OK" || echo "====> Failed create full env";
    #test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_vpc_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> VPC created OK" || echo "====> Failed create VPC";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_kube_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> KUBE created OK" || echo "====> Failed create KUBE";
    test $EXITCODE -ne 0 && exit $EXITCODE

   ./Only_kube_kandula_app.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> KUBE application created OK" || echo "====> Failed create KUBE application";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_kube_monitoring.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> MONITORING created OK" || echo "====> Failed create MONITORING";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_keys_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> KEYs were created OK" || echo "====> Failed creating KEYs";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_bastion_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> Bastion host created and configured OK" || echo "====> Failed create Bastion host";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_jenkins_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> Jenkins environment created OK" || echo "====> Failed create Jenkins environment";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_elk.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> ELK environment created OK" || echo "====> Failed create ELK environment";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_consul_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> Consul environment created OK" || echo "====> Failed create Consul environment";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_global_outputs.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> All servers and services started OK" || echo "====> Failed start main services";
    test $EXITCODE -ne 0 && exit $EXITCODE

    echo "================================================="
    echo -e "\n\n" "====>>>>BUILD ENTIRE ENVIRONMENT FINISHED WITH SUCCESS"
    echo "================================================="
} | tee "${SCRIPT_DIR}/../../FULL_CREATE_LOG.log"
