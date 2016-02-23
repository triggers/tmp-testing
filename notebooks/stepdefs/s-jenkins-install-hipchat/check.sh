#!/bin/bash
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

# Check do it file for pdf 105 install hipchat

ssh="ssh root@10.0.2.100 -i /home/centos/mykeypair"
jobs=(test-notification)
xml_file=(jenkins.plugins.hipchat.HipChatNotifier.xml
         sample-hipchat-0.xml)
jenkins_dir="/var/lib/jenkins"

xml_to_vm

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


${ssh} <<EOF 2> /dev/null

$(declare -f read_xml)
$(declare -f confirm_nested_values)
$(declare -f check_plugins_exists)
$(declare -f check_empty)
$(declare -f get_element_value)


! check_plugins_exists "hipchat" &&
    echo -e "${cross_mark} Plugins" || echo -e "${check_mark} Plugins"

! check_empty ${xml_file[0]} room && echo -e "${check_mark} HipChat Room" || echo -e "${cross_mark} HipChat Room"
! check_empty ${xml_file[0]} token && echo -e "${check_mark} HipChat Token" || echo -e "${cross_mark} HipChat Token"

[[ ! -d ${jenkins_dir}/jobs/${jobs[0]} ]] &&
    echo -e "${cross_mark} Job" || echo -e "${check_mark} Job"

! confirm_nested_values /home/${xml_file[1]} ${jenkins_dir}/jobs/${jobs[0]}/config.xml "notificationType notifyEnabled" && 
    echo -e "${cross_mark} Params" || echo -e "${check_mark} Params"

EOF
