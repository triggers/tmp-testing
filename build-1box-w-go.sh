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
    $starting_group "Build fresh openvz 1box image"
    (
	$starting_step "Clone axsh/vmapp-vdc-1box from github"
	[ -d "$DATADIR/vmapp-vdc-1box/.git" ]
	$skip_step_if_already_done ; set -e
	cd "$DATADIR"
	git clone https://github.com/axsh/vmapp-vdc-1box
    ) ; prev_cmd_failed

    (
	$starting_step "Clone hansode/vmbuilder from github"
	[ -f "$DATADIR/vmapp-vdc-1box/vmbuilder/.git" ]  # .git a file, because it is a submodule thingy
	$skip_step_if_already_done ; set -e
	cd "$DATADIR/vmapp-vdc-1box"
	make
    ) ; prev_cmd_failed

    (
	$starting_step "Do ./prepare-vmimage.sh openvz x86_64"
	openvzimagedir="$DATADIR/vmapp-vdc-1box/guestroot.openvz.x86_64/var/lib/wakame-vdc/images"
	openvzimages=(
	    lbnode.x86_64.openvz.md.raw.tar.gz
	    centos-6.6.x86_64.openvz.md.raw.tar.gz
	    lb-centos6.6-stud.x86_64.openvz.md.raw.tar.gz
	)
	for i in "${openvzimages[@]}"; do
	    [ -f "$openvzimagedir/$i" ] || break -1 2>/dev/null # return error from for loop
	done
	$skip_step_if_already_done ; set -e
	cd "$DATADIR/vmapp-vdc-1box"
	./prepare-vmimage.sh openvz x86_64
    ) ; prev_cmd_failed

    (
	$starting_step "Generate sshkey and login info for the to-be-built image"
	[ -f "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.sshkey" ]
	$skip_step_if_already_done ; set -e
	ssh-keygen -f  "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.sshkey" -N ""
	echo centos >"$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.sshuser"
	cat >>"$DATADIR/vmapp-vdc-1box/postcopy.txt" <<EOF
1box-openvz.netfilter.x86_64.raw.sshkey.pub /home/centos/.ssh/authorized_keys mode=644
EOF
    ) ; prev_cmd_failed

    (
	$starting_step "Build the raw OpenVZ 1box image with ./box-ctl.sh"
	[ -f "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw" ] ||
	    [ -f "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.tar.gz" ]
	$skip_step_if_already_done ; set -e
	cd "$DATADIR/vmapp-vdc-1box"
	./box-ctl.sh build openvz
    ) ; prev_cmd_failed

    (
	$starting_step "Make tar file of OpenVZ 1box image"
	[ -f "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.tar.gz" ]
	$skip_step_if_already_done ; set -e
	cd "$DATADIR/vmapp-vdc-1box"
	tar czSvf 1box-openvz.netfilter.x86_64.raw.tar.gz 1box-openvz.netfilter.x86_64.raw
    ) ; prev_cmd_failed
)

(
    $starting_group "Set up install GO in VM"
    (
	$starting_group "Set up vmdir"
	(
	    $starting_step "Make vmdir"
	    [ -d "$DATADIR/vmdir" ]
	    $skip_step_if_already_done ; set -e
	    mkdir "$DATADIR/vmdir"
	) ; prev_cmd_failed
	
	DATADIR="$DATADIR/vmdir" \
	       "$ORGCODEDIR/ind-steps/kvmsteps/kvm-setup.sh" \
	       "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.tar.gz"
    )

    (
	$starting_group "Install GO language in the OpenVZ 1box image"
	[ -f "$DATADIR/vmdir/1box-openvz-w-go.raw.tar.gz" ]
	$skip_group_if_unnecessary

	"$DATADIR/vmdir/kvm-boot.sh"

	(
	    $starting_step "Do yum install golang"
	    [ -f "$DATADIR/vmdir/1box-openvz-w-go.raw.tar.gz" ] || \
		[ "$("$DATADIR/vmdir/ssh-to-kvm.sh" which go )" = "/usr/bin/go" ]
	    $skip_step_if_already_done ; set -e
	    # Following this simple blog post: http://itekblog.com/centos-golang/
	    # Note: the vmbuilder scripts already install EPEL repository
	    "$DATADIR/vmdir/ssh-to-kvm.sh" sudo yum -y install go
	) ; prev_cmd_failed
	
	"$DATADIR/vmdir/kvm-shutdown-via-ssh.sh"
    )

    (
	$starting_step "Make snapshot of image with GO installed"
	[ -f "$DATADIR/vmdir/1box-openvz-w-go.raw.tar.gz" ]
	$skip_step_if_already_done ; set -e
	cd "$DATADIR/vmdir/"
	tar czSvf 1box-openvz-w-go.raw.tar.gz 1box-openvz.netfilter.x86_64.raw
    ) ; prev_cmd_failed
)

(
    $starting_step "Expand fresh image from snapshot of image with GO installed"
    [ -f "$DATADIR/vmdir/1box-openvz.netfilter.x86_64.raw" ]
    $skip_step_if_already_done ; set -e
    cd "$DATADIR/vmdir/"
    tar xzSvf 1box-openvz-w-go.raw.tar.gz
) ; prev_cmd_failed

"$DATADIR/vmdir/kvm-boot.sh"

# /home/centos/go/src/github.com/axsh/wakame-vdc/client/terraform-provider-wakamevdc/wakamevdc

(
    $starting_step "Initial go dir with wakame-vdc cloned"
    [ -f "$DATADIR/vmdir/1box-openvz-w-go.raw.tar.gz" ] && \
	"$DATADIR/vmdir/ssh-to-kvm.sh" '[ -d /home/centos/go/src ]'
    false # temporary hack to make this always run while debugging it
    $skip_step_if_already_done ; set -e
    "$DATADIR/vmdir/ssh-to-kvm.sh" <<EOF
set -x
set -e
mkdir -p go
export GOPATH=/home/centos/go
go get -v github.com/axsh/wakame-vdc/ || :
cd /home/centos/go/src/github.com/axsh/wakame-vdc/
git checkout terraform-provider
cd /home/centos/go/src/github.com/axsh/wakame-vdc/client/terraform-provider-wakamevdc/
go get -v
cd /home/centos/go/src/github.com/axsh/wakame-vdc/client/terraform-provider-wakamevdc/wakamevdc
export TF_ACC=something
export WAKAMEVDC_API_ENDPOINT="http://127.0.0.1:9001/api/12.03/"
go test -v
EOF
) ; prev_cmd_failed
