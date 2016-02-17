#!/bin/bash

thescript="$(cat <<EEE
reset-wakame.sh
EEE
)"

echo "Now executing the following script to do this task:"
echo "$thescript"
echo
echo "Output follows:"

bash <<<"$thescript"
