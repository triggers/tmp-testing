#!/bin/bash
. stepdefs/jenkins-utility/functions.sh

XML_FILE="jenkins.plugins.hipchat.HipChatNotifier.xml"
SSH="ssh root@10.0.2.100 -i /home/centos/mykeypair"

xml_to_vm

${SSH} <<EOF 2> /dev/null

$(declare -f check_client_exists)
$(declare -f reset_job)
cp /home/${XML_FILE} /var/lib/jenkins

service jenkins restart

EOF
