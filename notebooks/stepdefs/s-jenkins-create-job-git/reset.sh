#!/bin/bash
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

XML_FILE="sample-git-0.xml"
SSH="ssh root@10.0.2.100 -i /home/centos/mykeypair"

${SSH} [[ ! -f /home/${XML_FILE} ]] && scp -i /home/centos/mykeypair stepdefs/jenkins-config/${XML_FILE} root@10.0.2.100:/home &> /dev/null

${SSH} <<EOF 2> /dev/null

$(declare -f check_client_exists)
$(declare -f reset_job)

check_client_exists

echo "Creating default job..."
reset_job sample ${XML_FILE}

EOF
