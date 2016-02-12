#!/bin/bash
. /home/centos/notebooks/stepdefs/jenkins-utility/xml-utility.sh

function check_client_exists () {
    [[ ! -f jenkins-cli.jar ]] &&
        curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar
}

function check_plugins_exists () {    
    local plugins=($@)

    for plugin in ${plugins[@]}; do
        if [[ ! -f /var/lib/jenkins/plugins/${plugin}.jpi ]]; then
            java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin ${plugin}
            installed_new=0
        fi
    done

    if [[ ! -z ${installed_new} ]]; then service jenkins restart ; fi
}

function check_job_config () {
    local job=${1} cfg=${2} field_name=${3}
    local job_cfg=/var/lib/jenkins/jobs/${job}/config.xml

    
    if ! confirm_values /home/${cfg} ${job_cfg} ${field_name} ; then
        return 1
    fi
    return 0
}

function reset_job () {
    local job=${1} cfg=${2}

    if [[ -d /var/lib/jenkins/jobs/${1} ]] ; then
        java -jar jenkins-cli.jar -s http://localhost:8080 delete-job ${job}
    fi
    java -jar jenkins-cli.jar -s http://localhost:8080 create-job ${job} < /home/${cfg}
}
