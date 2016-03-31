#!/bin/bash

#bash $(dirname $0)/save.sh

. $(dirname $0)/stepdata.conf
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF 2> /dev/null
    $(declare -f check_param_value)

    check_param_value notificationType "SUCCESS STARTED FAILURE" ${job} && {
         echo "Added notifications: Passed"
         all_types_added=true
     } || echo "Check [ fail ]"

    # We need to make sure the jobs are created to pass this test as well.
    \$all_types_added && ! check_param_value notifyEnabled "false" ${job} && {
        echo "Enabled notifications: Passed"
     } || echo "Check [ fail ]"
EOF
