#!/bin/bash
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

SSH="ssh root@10.0.2.100 -i /home/centos/mykeypair"
XML_FILE="hudson.plugins.git.GitSCM.xml"

${SSH} <<EOF 2> /dev/null

$(declare -f check_empty)
$(declare -f get_element_value)

! check_empty ${XML_FILE} globalConfigName && echo "User ok" || echo "Missing parameter."
! check_empty ${XML_FILE} globalConfigEmail && echo "Email ok" || echo "Missing parameter."

EOF
