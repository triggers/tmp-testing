#!/bin/bash

out="$(ssh -qi ../mykeypair root@10.0.2.100 'service jenkins status' 2>&1)"
echo "$out"

if [[ "$out" == *jenkins*running* ]]; then
    echo "TASK COMPLETED"
else
    echo "THIS TASK HAS NOT BEEN DONE"
fi
