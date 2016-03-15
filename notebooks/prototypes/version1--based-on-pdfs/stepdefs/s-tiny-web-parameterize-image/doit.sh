#!/bin/bash

. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

# Doit file for filling in parameters that are missing in the imagebuild job
# Tasks:
#  Overwrite the jenkins created config.xml with predefined stored file.

ssh="ssh root@10.0.2.100 -i /home/centos/mykeypair"
job=tiny_web.imagebuild
xml_file=tiny_web.imagebuild.xml

${ssh} <<EOF 2> /dev/null

cp /home/${xml_file} /var/lib/jenkins/jobs/${job}/config.xml

EOF
