#!/bin/bash

. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

# Doit file for cloning wakmae-vdc to get access to mussel.
# Tasks:
#  Remove all current jobs from jenkins.

ssh="ssh root@10.0.2.100 -i /home/centos/mykeypair"

${ssh} <<EOF 2> /dev/null

for job in \$(java -jar jenkins-cli.jar -s http://localhost:8080 list-jobs) ; do
    echo "Deleting job \$job..."
    java -jar jenkins-cli.jar -s http://localhost:8080 delete-job "\$job"
done

EOF
