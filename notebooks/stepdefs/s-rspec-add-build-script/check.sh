#!/bin/bash

#bash $(dirname $0)/save.sh

. $(dirname $0)/stepdata.conf
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF  2> /dev/null
    content="\$(grep 'command' /var/lib/jenkins/jobs/${job}/config.xml)"
    [[ ! -z \$content ]] && echo " Check [ ok]" || "Check [ fail ]"
EOF
