#!/bin/bash

thescript="$(cat <<'EEE'

: ${IP:=10.0.2.100}
ssh -qi ../mykeypair root@$IP rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
EEE
)"

echo "Now executing the following script to do this step:"
echo "$thescript"
echo
echo "Output follows:"

bash <<<"$thescript"

echo "## End of Output ##"
