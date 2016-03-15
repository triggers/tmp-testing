#!/bin/bash

. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

# Doit file for installing plugins used in tiny_web_example
# Tasks:
#  Install jenkins-cli client if not installed.
#  Install the plugins git, git-client, rbenv and parameterized trigger.
#  Restart jenkins

ssh="ssh root@10.0.2.100 -i /home/centos/mykeypair"

${ssh} <<EOF 2> /dev/null

$(declare -f check_client_exists)
$(declare -f install_plugins)
$(declare -f check_plugins_exists)

check_client_exists

check_plugins_exists "git git-client rbenv parameterized-trigger" && {
    echo "All plugins installed."
} || {
    install_plugins "git git-client rbenv parameterized-trigger"
    service jenkins restart
}

EOF
