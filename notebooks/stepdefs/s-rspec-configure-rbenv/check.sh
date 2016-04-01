#!/bin/bash

#bash $(dirname $0)/save.sh

. $(dirname $0)/stepdata.conf
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF 2> /dev/null
    $(declare -f check_find_line_with)
    
    check_find_line_with ${job} 1 version 2.0.0-p598 && echo "Version: Passed" || echo "Check [ failed ]"
    check_find_line_with ${job} 1 gem__list bundler rake && echo "Gems: Passed" || echo "Check [ failed ]"
EOF
