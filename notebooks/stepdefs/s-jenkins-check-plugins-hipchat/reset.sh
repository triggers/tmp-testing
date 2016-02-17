#!/bin/bash
. stepdefs/jenkins-utility/functions.sh

SSH="ssh root@10.0.2.100 -i /home/centos/mykeypair"
${SSH} <<EOF 2> /dev/null

$(declare -f install_plugins)

install_plugins hipchat
service jenkins restart

EOF
