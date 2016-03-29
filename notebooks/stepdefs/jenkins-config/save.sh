#!/bin/bash

# set -euox

. $(dirname $0)/stepdata.conf
. /home/centos/notebooks/stepdefs/jenkins-utility/xml-utility.sh

function save_config() {
    local file="/var/lib/jenkins/jobs/${job}/config.xml"
    local xpath="${1}" element_name="${xpath##*/}"

    ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF 2> /dev/null
        $(declare -f xml_save_backup)
        xml_save_backup "${file}" "${element_name}" "${xpath}"
EOF
    scp -i /home/centos/mykeypair root@10.0.2.100:/tmp/"${element_name}".data-student $(dirname $0)/xml-data/ &> /dev/null
}

echo "Saving progress..."
[[ ${#xpaths} -eq 0 ]] || {
    for xpath in "${xpaths[@]}" ; do
        save_config "${xpath}"
    done
}
