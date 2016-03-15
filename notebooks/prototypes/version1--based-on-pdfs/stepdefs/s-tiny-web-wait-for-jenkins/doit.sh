#!/bin/bash

. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

# Doit file for waiting for jenkins plugsin.
# Tasks:
#  Wait while jenkins restarts

ssh="ssh root@10.0.2.100 -i /home/centos/mykeypair"

${ssh} <<EOF 2> /dev/null

while ! curl -I -s http://localhost:8080/ | grep -q "200 OK" ; do
    echo "Waiting for jenkins..."
    sleep 3
done 

echo "Jenkins is ready."

EOF



