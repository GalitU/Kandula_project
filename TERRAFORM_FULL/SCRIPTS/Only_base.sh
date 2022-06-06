 #!/bin/bash


path=`readlink -f "${BASH_SOURCE:-$0}"`

SCRIPT_DIR=`dirname $path`
#echo -e "\n\n" $SCRIPT_DIR
rm "${SCRIPT_DIR}/../../FULL_CREATE_LOG.log"
{
    ./Only_s3.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> VPC created OK" || echo "====> Failed create VPC";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_vpc_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> VPC created OK" || echo "====> Failed create VPC";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_keys_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> KEYs were created OK" || echo "====> Failed creating KEYs";
    test $EXITCODE -ne 0 && exit $EXITCODE

    ./Only_bastion_crt.sh
    EXITCODE=$?
    test $EXITCODE -eq 0 && echo -e "\n" "====> Bastion host created and configured OK" || echo "====> Failed create Bastion host";
    test $EXITCODE -ne 0 && exit $EXITCODE

    echo "================================================="
    echo -e "\n\n" "====>>>>BUILD only BASE ENVIRONMENT FINISHED WITH SUCCESS"
    echo "================================================="
} | tee "${SCRIPT_DIR}/../../FULL_CREATE_LOG.log"
