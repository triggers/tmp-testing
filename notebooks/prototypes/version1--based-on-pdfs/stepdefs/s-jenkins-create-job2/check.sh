#!/bin/bash
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

JOB=${1:-"sample2"}
XML_FILE="sample-2.xml"
SSH="ssh root@10.0.2.100 -i /home/centos/mykeypair"

xml_to_vm

${SSH} <<EOF 2> /dev/null

$(declare -f check_job_config)
$(declare -f get_element_value)
$(declare -f confirm_single_value)

if [[ ! -d /var/lib/jenkins/jobs/${JOB} ]] ; then
    echo "Something went wrong. Check previous steps."
elif ! check_job_config ${JOB} ${XML_FILE} "childProjects" confirm_single_value ; then
    echo "Something went wrong."
else
    echo "Configuration is correct"
fi

EOF
