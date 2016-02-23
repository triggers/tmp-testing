#!/bin/bash
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

# Check do it file for pdf 106 setup jenkins unit test.
# Evaluated Tasks:
#  Plugin installed: rbenv
#  Job test-rbenv created
#  Added shell script parameters to test-rbenv (config)

ssh="ssh root@10.0.2.100 -i /home/centos/mykeypair"
jenkins_dir="/var/lib/jenkins"

jobs=(test-rbenv)
xml_file=(sample-unit-test-0.xml)

# Read an xml file and retuns the contents from named element ($1)
# Starting from the line it is detected until and including the line where
# closure is detected. 
function read_xml() {
    local element_name=${1}
    local in_element=false
    let count=0
    while read -r ln; do
        case "$ln" in
            *\<"${element_name}"\>*)
                echo ${ln} | sed 's/<'${element_name}'>//g'
                in_element=true
                ;;
            # TODO: Find a better way to match elements which have attributes attached.
            # Currently breaks
            *\<"${element_name} "*)
                echo ${ln} | grep -oP '>\K.*?(?=<)'
                ;;
            *\</"${element_name}"\>*)
                echo ${ln} | sed 's/<\/'${element_name}'>//g'
                in_element=false
                ;;
            *)
                if $in_element; then
                    echo "$ln"
                fi
                ;;
        esac
    done
}

function confirm_attributed_single_value() {
    local try_xml=${1} target_xml=${2} element=${3}
    local target=$(cat ${try_xml} | read_xml ${element})
    local parsed=$(cat ${target_xml} | read_xml ${element})

    [[ "${target}" == "${parsed}" ]]
}

function confirm_multiline_values() {
    local try_xml=${1} target_xml=${2} element=${3}
    
    local parsed_values+=( "$(cat ${try_xml} | read_xml "${element}")" )
    local target_values+=( "$(cat ${target_xml} | read_xml "${element}")" )
    for req_value in "${target_values[@]}"; do
        if ! $(contains_value "${req_value}" "${parsed_values[@]}") ; then
            return 1
        fi
    done
}

xml_to_vm

${ssh} <<EOF 2> /dev/null


$(declare -f read_xml)
$(declare -f confirm_multiline_values)
$(declare -f confirm_attributed_single_value)
$(declare -f confirm_single_value)
$(declare -f get_element_value)
$(declare -f check_job_config)
$(declare -f contains_value)
$(declare -f check_plugins_exists)

! check_plugins_exists "rbenv" &&
    echo -e "${cross_mark} Plugins" || echo -e "${check_mark} Plugins"

[[ ! -d ${jenkins_dir}/jobs/${jobs[0]} ]] &&
    echo -e "${cross_mark} Jobs" || echo -e "${check_mark} Jobs"

pass=true

! confirm_attributed_single_value /home/${xml_file[0]} ${jenkins_dir}/jobs/${jobs[0]}/config.xml "version" && {
    echo -e "${cross_mark} param: ruby version"
    pass=false
}

! confirm_multiline_values /home/${xml_file[0]} ${jenkins_dir}/jobs/${jobs[0]}/config.xml "command" && {
    echo -e "${cross_mark} param: shell script"
    pass=false
}

\${pass} && echo -e "${check_mark} Params"

EOF
