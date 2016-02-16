#!/bin/bash
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

JOB=${1:-"sample"}
XML_FILE="sample-git-0.xml"
SSH="ssh root@10.0.2.100 -i /home/centos/mykeypair"


${SSH} <<EOF 2> /dev/null

$(declare -f check_job_config)
$(declare -f contains_value)
$(declare -f get_element_value)
$(declare -f confirm_single_value)

if [[ ! -d /var/lib/jenkins/jobs/${JOB} ]] ; then
    echo "Job missing."
elif ! check_job_config ${JOB} ${XML_FILE} url confirm_single_value ; then
    echo "Check config."
else 
    echo "Configuration is correct."
fi

EOF
