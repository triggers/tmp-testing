#!/bin/bash

out="$(ssh -qi ../mykeypair root@10.0.2.100 'rpm -qa' 2>&1)"

packages=(
    git 
    iputils nc 
    qemu-img 
    parted kpartx 
    rpm-build automake createrepo 
    openssl-devel zlib-devel readline-devel 
    gcc
)

ok=true
for p in "${packages[@]}"; do
    echo "$out" | grep ^"$p" || {
	echo "The package for $p was not installed"
	ok=false
	break
    }
done

if $ok; then
    echo "TASK COMPLETED"
else
    echo "THIS TASK HAS NOT BEEN DONE"
fi
