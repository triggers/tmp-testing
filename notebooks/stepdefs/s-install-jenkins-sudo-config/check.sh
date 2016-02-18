#!/bin/bash

out="$(ssh -qi ../mykeypair root@10.0.2.100 'grep jenkins /etc/sudoers' 2>&1)"

echo "$out"

if [[ "$out" == *jenkins* ]]; then
    echo "TASK COMPLETED"
else
    echo "THIS TASK HAS NOT BEEN DONE"
fi
