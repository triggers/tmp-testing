#!/bin/bash
. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

SSH="ssh root@10.0.2.100 -i /home/centos/mykeypair"

${SSH} <<EOF 2> /dev/null

$(declare -f check_plugins_exists)

if ! check_plugins_exists "git git-client" ; then
    echo "Missing plugin."
else
    echo "Configuration is correct"
fi

EOF
