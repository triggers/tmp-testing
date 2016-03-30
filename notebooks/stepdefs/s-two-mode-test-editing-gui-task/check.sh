#!/bin/bash

reportfailed()
{
    echo "Check failed: $*"
    exit
}

[ -f /tmp/afile ] || reportfailed "file /tmp/afile not found"

IFS= read -r -d '' contents </tmp/afile

pat='*name*goes*here*'

[[ "$contents" == $pat ]] && reportfailed "File has not been edited."

cp /tmp/afile "$(dirname "$0")"/useredits.info

echo "Check Passed"
