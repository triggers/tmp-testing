#!/bin/bash

# set -euox

. $(dirname $0)/stepdata.conf
. /home/centos/notebooks/stepdefs/jenkins-utility/xml-utility.sh

reboot=false

function load_config() {
    local file="/var/lib/jenkins/jobs/${job}/config.xml"
    local element_name="${1}" element_value="${2}"
    ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF  # 2> /dev/null
        $(declare -f xml_load_backup)

        value="\$(cat <<"XML_BLOCK"
$element_value
XML_BLOCK
)"
        xml_load_backup "${file}" "${element_name}" "\${value}"
EOF
}

echo "Loading progress..."
[[ ${#xml_nodes} -eq 0 ]] || {
    for param in "${xml_nodes[@]}" ; do
        student_file="$(dirname $0)/xml-data/${param%%@*}.data-student"
        [[ -f ${student_file} ]] && {
            load_config "${param%%@*}" "$(cat ${student_file})"
        }
    done
}
