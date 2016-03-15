#!/bin/bash

thescript="$(cat <<'EEE'
# This installs the Oracle version of Java.  The RPM file was
# already downloaded to /home/centos/notebooks/.downloads

: ${IP:=10.0.2.100}
cd /home/centos/notebooks/.downloads
tar c jdk-8u73-linux-x64.rpm | ssh -qi /home/centos/mykeypair root@$IP tar xv

ssh -qi /home/centos/mykeypair root@$IP <<EOS

rpm -ivh jdk-8u73-linux-x64.rpm

cat <<CFG >/etc/profile.d/java.sh
JAVA_HOME=/usr/java/jdk1.8.0_25/
PATH=$JAVA_HOME/bin:$PATH
export PATH JAVA_HOME
export CLASSPATH=.
CFG

EOS
EEE
)"

echo "Now executing the following script to do this step:"
echo "$thescript"
echo
echo "Output follows:"

bash <<<"$thescript"

echo "## End of Output ##"
