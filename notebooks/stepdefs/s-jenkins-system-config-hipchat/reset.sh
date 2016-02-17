#!/bin/bash
. stepdefs/jenkins-utility/functions.sh

XML_FILE="jenkins.plugins.hipchat.HipChatNotifier.xml"
SSH="ssh root@10.0.2.100 -i /home/centos/mykeypair"

${SSH} [[ ! -f /home/${XML_FILE} ]] && scp -i /home/centos/mykeypair stepdefs/jenkins-config/${XML_FILE} root@10.0.2.100:/home &> /dev/null

${SSH} <<EOF 2> /dev/null

$(declare -f check_client_exists)
$(declare -f reset_job)
cp /home/${XML_FILE} /var/lib/jenkins

service jenkins restart

EOF
