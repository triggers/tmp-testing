#!/bin/bash

set -e
cd "$(dirname $(readlink -f "$0"))"

case "$1" in
    tovm)
	rsync -avz -e ./vmdir/ssh-to-kvm.sh ./notebooks/ :/home/centos/notebooks
	;;
    fromvm)
	rsync -avz -e ./vmdir/ssh-to-kvm.sh :/home/centos/notebooks/ ./notebooks
	;;
    *) echo "First parameter should be tovm or fromvm"
       ;;
esac
