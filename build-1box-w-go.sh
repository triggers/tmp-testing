#!/bin/bash

reportfailed()		      
{
    echo "Script failed...exiting. ($*)" 1>&2
    exit 255
}

[ "$1" != "" ] && fullpath="$(readlink -f $1)"

export ORGCODEDIR="$(cd "$(dirname $(readlink -f "$0"))" && pwd -P)" || reportfailed

if [ "$DATADIR" = "" ]; then
    # Default to putting output in the code directory, which means
    # a separate clone of the repository for each build
    DATADIR="$ORGCODEDIR"
fi
source "$ORGCODEDIR/simple-defaults-for-bashsteps.source"

# avoids errors on first run, but maybe not good to change state
# outside of a step
touch "$DATADIR/datadir.conf"

source "$DATADIR/datadir.conf"
: ${imagesource:=$fullpath}

(
    $starting_checks "Clone axsh/vmapp-vdc-1box from github"
    [ -d "$DATADIR/vmapp-vdc-1box/.git" ]
    $skip_rest_if_already_done ; set -e
    cd "$DATADIR"
    git clone https://github.com/axsh/vmapp-vdc-1box
) ; prev_cmd_failed

(
    $starting_checks "Clone hansode/vmbuilder from github"
    [ -f "$DATADIR/vmapp-vdc-1box/vmbuilder/.git" ]  # .git a file, because it is a submodule thingy
    $skip_rest_if_already_done ; set -e
    cd "$DATADIR/vmapp-vdc-1box"
    make
) ; prev_cmd_failed

(
    $starting_checks "Do ./prepare-vmimage.sh lxc x86_64"
    lxcimagedir="$DATADIR/vmapp-vdc-1box/guestroot.lxc.x86_64/var/lib/wakame-vdc/images"
    lxcimages=(
	lbnode.x86_64.lxc.md.raw.tar.gz
	centos-6.6.x86_64.lxc.md.raw.tar.gz
	lb-centos6.6-stud.x86_64.lxc.md.raw.tar.gz
    )
    for i in "${lxcimages[@]}"; do
	[ -f "$lxcimagedir/$i" ] || break -1 2>/dev/null # return error from for loop
    done
    $skip_rest_if_already_done ; set -e
    cd "$DATADIR/vmapp-vdc-1box"
    ./prepare-vmimage.sh lxc x86_64
) ; prev_cmd_failed
