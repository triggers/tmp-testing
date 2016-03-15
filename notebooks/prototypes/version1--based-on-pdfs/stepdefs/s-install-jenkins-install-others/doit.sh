#!/bin/bash

thescript="$(cat <<'EEE'
: ${IP:=10.0.2.100}

ssh -qi /home/centos/mykeypair root@$IP <<'EOS'

yum install -y git iputils nc qemu-img parted kpartx rpm-build automake createrepo openssl-devel zlib-devel readline-devel gcc

EOS
EEE
)"

echo "Now executing the following script to do this step:"
echo "$thescript"
echo
echo "Output follows:"

bash <<<"$thescript"

echo "## End of Output ##"
