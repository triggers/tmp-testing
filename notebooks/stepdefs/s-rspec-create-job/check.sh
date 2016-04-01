#!/bin/bash

. $(dirname $0)/stepdata.conf

ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF 2> /dev/null
    [[ -d /var/lib/jenkins/jobs/${job} ]] && echo "This task has been done" || {
        Job missing
    }
EOF
