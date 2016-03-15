#!/bin/bash

thescript="$(cat <<'EEE'

: ${IP:=10.0.2.100}
ssh -qi ../mykeypair root@$IP curl -fSkL http://pkg.jenkins-ci.org/redhat/jenkins.repo -o /etc/yum.repos.d/jenkins.repo

EEE
)"

echo "Now executing the following script to do this step:"
echo "$thescript"
echo
echo "Output follows:"

bash <<<"$thescript"

echo "## End of Output ##"
