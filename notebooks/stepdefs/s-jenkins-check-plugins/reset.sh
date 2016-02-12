#!/bin/bash
. stepdefs/jenkins-utility/functions.sh

XML_FILE="sample-1.xml"
SSH="ssh root@10.0.2.100 -i /home/centos/mykeypair"

${SSH} [[ ! -f /home/${XML_FILE} ]] && scp -i /home/centos/mykeypair stepdefs/jenkins-config/${XML_FILE} root@10.0.2.100:/home &> /dev/null

${SSH} <<EOF 2> /dev/null

$(declare -f check_plugins_exists)
$(declare -f install_plugin)

install_plugins git git-client
service jenkins restart

EOF
