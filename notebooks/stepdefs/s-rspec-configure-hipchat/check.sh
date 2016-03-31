#!/bin/bash

#bash $(dirname $0)/save.sh

. $(dirname $0)/stepdata.conf
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF 2> /dev/null
    $(declare -f check_param value)

    check_param_value notificationType "SUCCESS STARTED FAILURE" ${job} && echo "Added notifications: Passed" || echo "Check [ fail ]"
    check_param_value notifyEnabled "false" ${job} && echo "Check [ fail ]" || echo "Enabled notifications: Passed"
EOF
