#!/bin/bash

out="$(ssh -qi ../mykeypair root@10.0.2.100 'grep requiretty /etc/sudoers' 2>&1)"

out2="$(echo "$out" | grep -v '^ *#')"

# so out2 is now "lines with requiretty that do not begin with a comment character"

if [ "$out2" = "" ]; then
    echo "TASK COMPLETED"
else
    echo "THIS TASK HAS NOT BEEN DONE"
fi
