#!/bin/bash

# TODO: make this script be called only when
# the previously executed cell was a "provided-script cell"
bash $(dirname $0)/save.sh

. $(dirname $0)/stepdata.conf
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF  2> /dev/null
    $(declare -f check_not_empty)
    check_not_empty ${job} url && echo "Check [ ok ]" || echo "Check [ fail ]"
EOF
