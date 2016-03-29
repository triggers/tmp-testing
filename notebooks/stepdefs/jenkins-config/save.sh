#!/bin/bash

# set -euox

. $(dirname $0)/stepdata.conf
. /home/centos/notebooks/stepdefs/jenkins-utility/xml-utility.sh

function save_config() {
    local file="/var/lib/jenkins/jobs/${job}/config.xml"
    local element_name="${1}" xpath="${2}"
    ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF  # 2> /dev/null
        $(declare -f xml_save_backup)
        xml_save_backup "${file}" "${element_name}" "${xpath}"
EOF
    scp -i /home/centos/mykeypair root@10.0.2.100:/tmp/"${element_name}".data $(dirname $0)/xml-data/"${element_name}".data-student &> /dev/null
}

[[ ${#xml_nodes} -eq 0 ]] || {
    for param in "${xml_nodes[@]}" ; do
        save_config "${param%%@*}" "${param#*@}"
    done
}
