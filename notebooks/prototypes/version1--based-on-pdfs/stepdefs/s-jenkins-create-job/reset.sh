#!/bin/bash
. stepdefs/jenkins-utility/functions.sh

XML_FILE="sample-0.xml"
SSH="ssh root@10.0.2.100 -i /home/centos/mykeypair"

xml_to_vm

${SSH} <<EOF 2> /dev/null

$(declare -f check_client_exists)
$(declare -f reset_job)

check_client_exists

echo "Creating default job..."
reset_job sample ${XML_FILE}

EOF
