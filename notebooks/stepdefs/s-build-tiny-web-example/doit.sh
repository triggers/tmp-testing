#!/bin/bash

. /home/centos/notebooks/stepdefs/jenkins-utility/functions.sh

# Reset file for pdf 103 execute jenkins job
# Tasks:
#  Install jenkins-cli client if not installed.
#  Create job, sample using predefind configuration file.
#  Create job, sample2 using predefined configuration file.

ssh="ssh root@10.0.2.100 -i /home/centos/mykeypair"

# Currently imagebuild needs to be the last job or the parameters for
# parameterized trigger will not be set.

jobs=(tiny_web.rspec
      tiny_web.rpmbuild
      tiny_web.rpmpublish
      tiny_web.integration
      tiny_web.imagebuild)

xml_file=(tiny_web.rspec.xml
          tiny_web.rpmbuild.xml
          tiny_web.rpmpublish.xml
          tiny_web.integration.xml
          tiny_web.imagebuild.xml)

xml_to_vm

${ssh} <<EOF 2> /dev/null

$(declare -f reset_job)
$(declare -f check_client_exists)
$(declare -f install_plugins)

check_client_exists
install_plugins "git git-client rbenv parameterized-trigger"

for job in ${jobs[@]} ; do
    reset_job \$job \$job.xml
done

service jenkins restart

EOF
