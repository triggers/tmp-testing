#!/bin/bash

ssh -qi ../mykeypair root@10.0.2.100 uptime

if [ "$?" = "0" ]; then
    echo "TASK COMPLETED"
else
    echo "THIS TASK HAS NOT BEEN DONE"
fi
