#!/bin/bash

original='\033[0m'
red='\033[00;31m'
green='\033[00;32m'
check_mark="[${green}\xE2\x9C\x93${original}]"
cross_mark="[${red}\xE2\x9C\x97${original}]"

function install_client () {
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

function check_not_empty () {
    local job=${1} element=${2}
    local content=$(grep -oP '(?<=<'${element}'>).*?(?=</'${element}'>)' /var/lib/jenkins/jobs/${job}/config.xml)

    [[ ! -z $content ]]
}

function reset_job () {
    local job=${1} cfg=${2}

    if [[ -d /var/lib/jenkins/jobs/${1} ]] ; then
        java -jar jenkins-cli.jar -s http://localhost:8080 delete-job ${job}
    fi
    echo "Creating default job for ${job}..."
    java -jar jenkins-cli.jar -s http://localhost:8080 create-job ${job} < /home/${cfg}
}
