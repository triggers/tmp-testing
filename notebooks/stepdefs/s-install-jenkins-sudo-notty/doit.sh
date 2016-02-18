#!/bin/bash

thescript="$(cat <<'EEE'
: ${IP:=10.0.2.100}

ssh -qi /home/centos/mykeypair root@$IP <<'EOS' 2>/dev/null

sed -i "s/^\(^Defaults\s*requiretty\).*/# \1/" /etc/sudoers

EOS
EEE
)"

echo "Now executing the following script to do this step:"
echo "$thescript"
echo
echo "Output follows:"

bash <<<"$thescript"

echo "## End of Output ##"
