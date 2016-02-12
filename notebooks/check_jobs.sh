#!/bin/bash
source functions.sh
source jenkins.source

${SSH} <<EOF
 date
EOF

# if [[ -z ${job} ]]; then
#     echo "No job specified"
#     exit 0
# elif [[ ${job} == "default" ]]; then
#     echo "Creating default job..."
#     job="sample"
#     reset_job
# fi

# if evaluate_job_config; then echo "Configuration is correct" ; else echo "Something went wrong." ; fi
