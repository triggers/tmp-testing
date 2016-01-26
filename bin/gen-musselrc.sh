#!/bin/bash
#
set -e
set -o pipefail
set -u

# setup musselrc

cat <<EOS > ~/.musselrc
DCMGR_HOST=127.0.0.1
account_id=a-shpoolxx
EOS
