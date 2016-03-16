#!/bin/bash

ymloutput="$(mussel instance index)"

# TODO: parse this better!

(
    if [[ "$ymloutput" != *running* ]]; then
	echo "ERROR: No instances are running"
	exit 1
    fi

    if [[ "$ymloutput" != *cpu_cores:\ 2* ]]; then
	echo "ERROR: Instance must have 2 CPUs"
	exit 1
    fi

    if [[ "$ymloutput" != *10.0.2.100* ]]; then
	echo "WARNING: IP address of instance is not 10.0.2.100"
    fi
)

if [ "$?" = "0" ]; then
    echo "TASK COMPLETED"
else
    echo "THIS TASK HAS NOT BEEN DONE"
fi
