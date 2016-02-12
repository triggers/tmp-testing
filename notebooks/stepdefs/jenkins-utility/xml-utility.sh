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

# Extracts data from a xml file ($1) and specified element ($2)
# and returns as a string in array format, i.e. "value1 value2..."

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


# Try one xml file ($2) vs a base file ($1) and make sure element ($3) in both files
# contains the same data. Returns true when all required data is present.

function confirm_values () {
    local target_xml=${1} try_xml=${2} element_name=${3}
    local required_values=( $(get_element_values ${target_xml} ${element_name}) )
    local parsed_values=( $(get_element_values ${try_xml} ${element_name}) )
    
    for required_value in ${required_values[@]}; do
        if ! $(contains_value "${required_value}" ${parsed_values[@]}) ; then
            echo "[ERROR]: Missing value. ${required_value}"  # Added missing value for debuging
            return 1
        fi
    done
    return 0
}
