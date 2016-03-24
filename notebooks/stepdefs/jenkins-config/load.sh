#!/bin/bash

# set -euox

. $(dirname $0)/stepdata.conf

reboot=false

function load_config() {
    local file="/var/lib/jenkins/jobs/${job}/config.xml"
    local element_name="${1}"
    local element_value="${2}"
    ssh -i /home/centos/mykeypair root@10.0.2.100 <<EOF

    # In case there is a element without closing tag we need to remove with a different
    # match than when removing a code block

        has_end=\$(grep "</${element_name}>" ${file})
        echo \$has_end
        [[ -z \$has_end ]] && sed -i '/'${element_name}'/c\' ${file}

    # Remove existing element if exists to avoid duplicates
    # in case of loading the same block multiple times.

        sed -i '/<'${element_name}'/,/<\/'${element_name}'>/d' ${file}

    # TODO: revise wether this is necessary or not

        cat <<EOS > xml-data.dat
$(cat xml-data.dat)
EOS
        sed -i '/<project>/r xml-data.dat' ${file}
        yes | rm xml-data.dat
        $reboot && service jenkins restart
EOF
}

[[ ${#config_params} -eq 0 ]] || {
    for param in "${config_params[@]}" ; do
        load_config "${param%%=*}" "${param#*=}"
    done
}


