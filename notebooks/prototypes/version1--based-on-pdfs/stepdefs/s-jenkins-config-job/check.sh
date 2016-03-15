#!/bin/bash
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

JOB=${1:-"sample"}
XML_FILE="sample-1.xml"
SSH="ssh root@10.0.2.100 -i /home/centos/mykeypair"

xml_to_vm

${SSH} <<EOF 2> /dev/null

$(declare -f check_job_config)
$(declare -f contains_value)
$(declare -f get_element_values)
$(declare -f confirm_values)

if [[ ! -d /var/lib/jenkins/jobs/${JOB} ]] ; then
    echo "Something went wrong. Check previous step."
elif ! check_job_config ${JOB} ${XML_FILE} "command" confirm_values ; then
    echo "Something went wrong."
else 
    echo "Configuration is correct."
fi

EOF
