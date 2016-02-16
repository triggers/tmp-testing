#!/bin/bash

# Compares a string value ($1) to all values in an array ($2)
# and returns true if a match is found.

function contains_value() {
    local match=${1}

    for value in "${@:2}"; do
        [[ "${match}" == "${value}" ]] &&
            return 0;
    done
    return 1
}

# Extracts data from a xml file ($1) at specified element ($2) where
# multiple lines needs to be parsed.

function get_element_values () {
    local filename=${1} element_name=${2}
    local values=$(
        cat ${filename} | \
            sed -n '/.*\<'${element_name}'\>/,/\<\/'${element_name}'\>/p' | \
            sed 's|<'${element_name}'>||' | \
            sed 's|</'${element_name}'>||'
          )

    echo ${values}
}

# Extracts data from xml file ($1) at specified element ($2) where
# parameter is single line.

function get_element_value () {
    local filename=${1} element_name=${2}
    local value=$(
        cat ${filename} | \
            grep "${element_name}" | \
            sed 's|<'${element_name}'>||' | \
            sed 's|</'${element_name}'>||'
          )

    echo ${value}
}

# Try one xml file ($2) vs a base file ($1) and make sure element ($3) in both files
# contains the same data. Returns true when all required data is present.

function confirm_values () {
    local target_xml=${1} try_xml=${2} element_name=${3}
    local required_values=( $(get_element_values ${target_xml} ${element_name}) )
    local parsed_values=( $(get_element_values ${try_xml} ${element_name}) )

    # Possible TODO: Deal with cases where the same command appears more than one time
    # (remove item on match)
    
    for required_value in ${required_values[@]}; do
        if ! $(contains_value "${required_value}" ${parsed_values[@]}) ; then
            echo "[ERROR]: Missing value. ${required_value}"
            return 1
        fi
    done
    return 0
}

# For single value.

function confirm_single_value () {
    local target_xml=${1} try_xml=${2} element_name=${3}
    local required_value=$(get_element_value ${target_xml} ${element_name})
    local parsed_value=$(get_element_value ${try_xml} ${element_name})
    if [[ "${parsed_value}" == "${required_value}" ]] ; then
        return 0
    fi
    return 1
}
