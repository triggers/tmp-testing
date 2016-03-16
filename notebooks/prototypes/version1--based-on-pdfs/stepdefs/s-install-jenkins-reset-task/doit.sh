#!/bin/bash

thescript="$(cat <<EEE
reset-wakame.sh

# This sleep is necessary so Wakame-vdc will reuse the 10.0.2.100 IP
# addresss.
sleep 15  # TODO: remove the need for this

EEE
)"

echo "Now executing the following script to do this task:"
echo "$thescript"
echo
echo "Output follows:"

bash <<<"$thescript"

echo "## End of Output ##"
