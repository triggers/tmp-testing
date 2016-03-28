#!/bin/bash

# set -euox

. $(dirname $0)/stepdata.conf
. ../jenkins-utility/xml-utility.sh

reboot=false

function load_config() {
    local file="/var/lib/jenkins/jobs/${job}/config.xml"
    local element_name="${1}" element_value="${2}"
    ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF  # 2> /dev/null
        $(declare -f xml_load_backup)
        xml_load_backup "${file}" "${element_name}" "${element_value}"
EOF
}

[[ ${#xml_nodes} -eq 0 ]] || {
    for param in "${xml_nodes[@]}" ; do
        load_config "${param%%.*}" "$(cat $(dirname $0)/xml-data/${param})"
    done
}
