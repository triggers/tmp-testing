#!/bin/bash

reportfailed()
{
    echo "Check failed: $*"
    exit
}

[ -f /tmp/afile ] || reportfailed "file /tmp/afile not found"

IFS= read -r -d '' contents </tmp/afile

[ "$contents" = "" ] || echo "(Note: file is currently not empty)"

echo "Check Passed"
