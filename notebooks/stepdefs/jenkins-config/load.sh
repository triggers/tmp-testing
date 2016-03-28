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

[[ ${#load_params} -eq 0 ]] || {
    for param in "${load_params[@]}" ; do
        load_config "${param%%=*}" "${param#*=}"
    done
}



#     local old_ifs=$IFS IFS="\n"
#     while read -r line ; do
# 	[[ "${line}" == *"/"* ]] && echo ${line}
#         element_value="$element_value${line}\n"
#     done <<< "$2"
#     IFS=$old_ifs

#     element_value=${element_value%\\n*}


#         has_end=\$(grep "</${element_name}>" ${file})
#          [[ -z \$has_end ]] && { sed -i '/'${element_name}'/c\'"${element_value}"'' ${file} ; } || {
# 	 echo fdsf
# #            sed -n '/'${element_name}'/{:a;N;/'${element_name}'/!ba;N;s/.*\n/'"${element_value}"'\n/};p'
# #            sed '/<'${element_name}'/,/<\/'${element_name}'>/p' ${file}
#          }

# EOF
