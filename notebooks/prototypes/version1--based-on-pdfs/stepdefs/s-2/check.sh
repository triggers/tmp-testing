#!/bin/bash

ymloutput="$(mussel instance index)"

# TODO: parse this better!

if [[ "$ymloutput" != *running* ]]; then
    echo "ERROR: No instances are running"
    exit
fi

if [[ "$ymloutput" != *cpu_cores:\ 2* ]]; then
    echo "ERROR: Instance must have 2 CPUs"
    exit
fi

if [[ "$ymloutput" != *10.0.2.100* ]]; then
    echo "WARNING: IP address of instance is not 10.0.2.100"
fi

echo "OK: Instance was started successfully."
