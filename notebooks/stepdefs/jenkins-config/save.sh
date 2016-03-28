#!/bin/bash

# set -euox

. $(dirname $0)/stepdata.conf
. /home/centos/notebooks/stepdefs/jenkins-utility/xml-utility.sh

function save_config() {
    local file="/var/lib/jenkins/jobs/${job}/config.xml"
    local element_name="${1}" param="${2}"
    ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF  # 2> /dev/null
        $(declare -f xml_save_backup)
        xml_save_backup "${file}" "${element_name}" "${param}"
EOF
    scp -i /home/centos/mykeypair root@10.0.2.100:/tmp/"${element_name}".data $(dirname $0)/xml-data/"${element_name}".data-student &> /dev/null
}

[[ ${#xml_nodes} -eq 0 ]] || {
    for param in "${xml_nodes[@]}" ; do
        if [[ $(wc -l < $(dirname $0)/xml-data/${param}) -eq 0 ]] ; then
             save_config "${param%%.*}"
         else
             save_config "${param%%.*}" "multi"
         fi
    done
}
#  $(sed -i 's/'"${param}"'/'"${param}"'='"${data}"'/g' stepdata.conf)
