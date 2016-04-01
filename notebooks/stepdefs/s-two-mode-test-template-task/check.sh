#!/bin/bash

reportfailed()
{
    echo "Check failed: $*"
    exit
}

[ -f /tmp/afile ] || reportfailed "file /tmp/afile not found"

IFS= read -r -d '' contents </tmp/afile

[[ "$contents" = First*Your*name*Last* ]] || reportfailed "Contents of /tmp/afile do not look correct"

echo "Check Passed"
