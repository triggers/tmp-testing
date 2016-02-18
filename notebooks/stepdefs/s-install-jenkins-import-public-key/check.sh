#!/bin/bash

KEYFILE=/tmp/jenkins-ci.org.key
[ -f $KEYFILE ] || \
    wget http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key \
	 -O $KEYFILE 2>/dev/null

ssh -qi ../mykeypair root@10.0.2.100 <<EOF 2>/dev/null
KEYID=$(echo $(gpg --throw-keyids < $KEYFILE)|cut -c11-18|tr [A-Z] [a-z])
rpm -q gpg-pubkey-\$KEYID
EOF

if [ "$?" = "0" ]; then
    echo "TASK COMPLETED"
else
    echo "THIS TASK HAS NOT BEEN DONE"
fi
