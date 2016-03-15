#!/bin/bash

: ${IP:=10.0.2.100}
ssh -qi ../mykeypair root@$IP '[ -f /etc/yum.repos.d/jenkins.repo ]'

if [ "$?" = "0" ]; then
    echo "TASK COMPLETED"
else
    echo "THIS TASK HAS NOT BEEN DONE"
fi
