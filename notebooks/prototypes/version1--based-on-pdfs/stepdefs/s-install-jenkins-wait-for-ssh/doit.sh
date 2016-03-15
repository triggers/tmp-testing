#!/bin/bash

thescript="$(cat <<'EEE'

: ${IP:=10.0.2.100}
while [[ "$(echo | nc -w 1 "$IP" 22)" != *SSH* ]]; do
  sleep 2
  echo "Waiting on SSH at $IP..."
done
echo "SSH is active at $IP, port 22"

EEE
)"

echo "Now executing the following script to do this step:"
echo "$thescript"
echo
echo "Output follows:"

bash <<<"$thescript"

echo "## End of Output ##"
