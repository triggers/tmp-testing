#!/bin/bash

reportfailed()
{
    echo "Check failed: $*"
    exit
}

[ -f /tmp/thedate ] || reportfailed "file /tmp/thedate not found"

[[ "$(< /tmp/thedate)" == *JST* ]] || reportfailed "contents of /tmp/thedate does not seem to be a date"

echo "Check Passed"
