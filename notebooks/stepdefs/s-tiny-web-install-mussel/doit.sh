#!/bin/bash

. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

# Doit file for cloning wakmae-vdc to get access to mussel.
# Tasks:
#  Clone wakame-vdc from.

ssh="ssh root@10.0.2.100 -i /home/centos/mykeypair"

${ssh} <<EOF 2> /dev/null


[ -f /opt/axsh/wakame-vdc/client/mussel/bin/mussel ] && {
    echo "Mussel is installed."
} || {
    mkdir /opt/axsh/
    cd /opt/axsh
    git clone https://github.com/axsh/wakame-vdc.git
}

EOF
