#!/bin/bash
. /home/centos/notebooks/stepdefs/jenkins-utility/xml-utility.sh

function check_client_exists () {
    [[ ! -f jenkins-cli.jar ]] &&
        curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar
}

function check_plugins_exists () {
    for plugin in $@;  do
        if [[ ! -f /var/lib/jenkins/plugins/${plugin}.jpi ]]; then
            return 1
        fi
    done
}

function install_plugins () {
    for plugin in $@;  do
        if [[ ! -f /var/lib/jenkins/plugins/${plugin}.jpi ]]; then
            java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin ${plugin}
        fi
    done
}

function check_empty () {
    local cfg=${1} parameter=${2}
    [[ -z $(get_element_value /var/lib/jenkins/${cfg} ${parameter}) ]]
}

function reset_job () {
    local job=${1} cfg=${2}

    if [[ -d /var/lib/jenkins/jobs/${1} ]] ; then
        java -jar jenkins-cli.jar -s http://localhost:8080 delete-job ${job}
    fi
    java -jar jenkins-cli.jar -s http://localhost:8080 create-job ${job} < /home/${cfg}
}

function check_job_config () {
    local job=${1} cfg=${2} field_name=${3} confirm=${4:-confirm_values}
    local job_cfg=/var/lib/jenkins/jobs/${job}/config.xml

    $confirm /home/${cfg} ${job_cfg} "${field_name}" || return 1
}
