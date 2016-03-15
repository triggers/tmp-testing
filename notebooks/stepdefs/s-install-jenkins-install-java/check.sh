#!/bin/bash

out="$(ssh -qi ../mykeypair root@10.0.2.100 'java -version' 2>&1)"
echo "$out"

if [[ "$out" == *java*version*1.8* ]]; then
    echo "TASK COMPLETED"
else
    echo "THIS TASK HAS NOT BEEN DONE"
fi
