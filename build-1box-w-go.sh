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
    $starting_checks "Do ./prepare-vmimage.sh openvz x86_64"
    openvzimagedir="$DATADIR/vmapp-vdc-1box/guestroot.openvz.x86_64/var/lib/wakame-vdc/images"
    openvzimages=(
	lbnode.x86_64.openvz.md.raw.tar.gz
	centos-6.6.x86_64.openvz.md.raw.tar.gz
	lb-centos6.6-stud.x86_64.openvz.md.raw.tar.gz
    )
    for i in "${openvzimages[@]}"; do
	[ -f "$openvzimagedir/$i" ] || break -1 2>/dev/null # return error from for loop
    done
    $skip_rest_if_already_done ; set -e
    cd "$DATADIR/vmapp-vdc-1box"
    ./prepare-vmimage.sh openvz x86_64
) ; prev_cmd_failed

(
    $starting_checks "Generate sshkey and login info for the to-be-built image"
    [ -f "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.sshkey" ]
    $skip_rest_if_already_done ; set -e
    ssh-keygen -f  "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.sshkey" -N ""
    echo centos >"$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.sshuser"
    cat >>"$DATADIR/vmapp-vdc-1box/postcopy.txt" <<EOF
1box-openvz.netfilter.x86_64.raw.sshkey.pub /home/centos/.ssh/authorized_keys mode=644
EOF
) ; prev_cmd_failed

(
    $starting_checks "Build the raw OpenVZ 1box image with ./box-ctl.sh"
    [ -f "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw" ] ||
	[ -f "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.tar.gz" ]
    $skip_rest_if_already_done ; set -e
    cd "$DATADIR/vmapp-vdc-1box"
    ./box-ctl.sh build openvz
) ; prev_cmd_failed

(
    $starting_checks "Make tar file of OpenVZ 1box image"
    [ -f "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.tar.gz" ]
    $skip_rest_if_already_done ; set -e
    cd "$DATADIR/vmapp-vdc-1box"
    tar czSvf 1box-openvz.netfilter.x86_64.raw.tar.gz 1box-openvz.netfilter.x86_64.raw
) ; prev_cmd_failed

(
    $starting_dependents "Set up vmdir"
    (
	$starting_checks "Make vmdir"
	[ -d "$DATADIR/vmdir" ]
	$skip_rest_if_already_done ; set -e
	mkdir "$DATADIR/vmdir"
    ) ; prev_cmd_failed
    
    DATADIR="$DATADIR/vmdir" \
	   "$ORGCODEDIR/ind-steps/kvmsteps/kvm-setup.sh" \
	   "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.tar.gz"
    true
    $skip_rest_if_already_done
)

"$DATADIR/vmdir/kvm-boot.sh"

(
    $starting_checks "Do yum install golang"
    [ "$("$DATADIR/vmdir/ssh-to-kvm.sh" which go )" = "/usr/bin/go" ]
    $skip_rest_if_already_done ; set -e
    # Following this simple blog post: http://itekblog.com/centos-golang/
    # Note: the vmbuilder scripts already install EPEL repository
    "$DATADIR/vmdir/ssh-to-kvm.sh" sudo yum instal go
) ; prev_cmd_failed
