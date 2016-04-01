#!/bin/bash

original='\033[0m'
red='\033[00;31m'
green='\033[00;32m'
check_mark="[${green}\xE2\x9C\x93${original}]"
cross_mark="[${red}\xE2\x9C\x97${original}]"

function check_plugins_exists () {
    for plugin in $@;  do
        if [[ ! -f /var/lib/jenkins/plugins/${plugin}.jpi ]]; then
            return 1
        fi
    done
}

function check_not_empty () {
    local job=${1} element=${2}
    local content=$(grep -oP '(?<=<'${element}'>).*?(?=</'${element}'>)' /var/lib/jenkins/jobs/${job}/config.xml)

    [[ ! -z $content ]]
}

function check_param_value() {
    local element="${1}" required_values="${2}" job="${3}"
    local content="$(grep -oP '(?<=<'${element}'>).*?(?=</'${element}'>)' /var/lib/jenkins/jobs/${job}/config.xml)"
    for value in ${required_values} ; do
        [[ "${content}" != *"${value}"* ]] && {
            return 1
        }
    done
    return 0
}

# Recieves a job name ($1), number of times ($2) the pattern needs to be found
# and a list of keywords that a line should consist of
function check_find_line_with() {
    local job="${1}" ; shift
    local passed_check=
    local occurances="${1}" ; shift
    let found=0

    while read -r line ; do
        passed_check=true
        for keyword in $@ ; do
            [[ ${line} != *"${keyword}"* ]] && { passed_check=false ; break ; }
        done
        $passed_check && {
            found=$(( $found+1 ))
            [[ $found -eq $occurances ]] && return 0
        }
    done < /var/lib/jenkins/jobs/${job}/config.xml
    return 1
}
