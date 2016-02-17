#!/bin/bash
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

function read_xml() {
    local element_name=${1}
    local in_element=false
    let count=0
    while read -r ln; do
        case "$ln" in
            *\<${element_name}\>*)
                in_element=true
                count=$(( ${count} + 1  ))
                ;;
            *\</${element_name}\>*)
                in_element=false
                ;;
            *)
                if $in_element; then
                    echo "$count $ln"
                fi
                ;;
        esac
    done
}

function confirm_nested_values () {
    local target_xml=${1} try_xml=${2}
    local required_values=("${3}")
    local target_values=() parsed_values=()
    for value in ${required_values[@]}; do
        target_values+=( $(cat ${target_xml} | \
                                  read_xml "jenkins.plugins.hipchat.model.NotificationConfig" | \
                                  grep -oP '(?<=<'${value}'>).*?(?=</'${value}'>)')
                       )
        parse_values+=( $(cat ${try_xml} | \
                                  read_xml "jenkins.plugins.hipchat.model.NotificationConfig" | \
                                  grep -oP '(?<=<'${value}'>).*?(?=</'${value}'>)')
                      )
    done

    # TODO: Switch to compare the contents of the arrays instead
    [[ "${parse_values[@]}" == "${target_values[@]}" ]] || return 1
}


JOB=${1:-"test-notification"}
XML_FILE="sample-hipchat-0.xml"
SSH="ssh root@10.0.2.100 -i /home/centos/mykeypair"

${SSH} <<EOF 2> /dev/null

$(declare -f check_job_config)
$(declare -f read_xml)
$(declare -f confirm_nested_values)


if [[ ! -d /var/lib/jenkins/jobs/${JOB} ]] ; then
    echo "Job missing."
elif ! confirm_nested_values /home/${XML_FILE} /var/lib/jenkins/jobs/${JOB}/config.xml "notificationType notifyEnabled" ; then
    echo "Check config."
else 
    echo "Configuration is correct."
fi

EOF
