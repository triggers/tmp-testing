#!/bin/bash

[ -f /tmp/afile ] || exit

IFS= read -r -d '' contents </tmp/afile

pat='*name*goes*here*'
set -x
[[ "$contents" == $pat ]] || exit

infofile="$(dirname "$0")"/useredits.info
[ -f "$infofile" ] || exit

edits="$(grep 'Your name' "$infofile")"

sed -i "s/name goes here/${edits#*: }/" /tmp/afile 
