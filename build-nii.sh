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

DATADIR="$DATADIR" "$ORGCODEDIR/ind-steps/build-1box/build-1box.sh"

(
    $starting_group "Set up install Jupyter in VM"
    (
	$starting_group "Set up vmdir"
	[ -x "$DATADIR/vmdir/kvm-boot.sh" ]
	$skip_group_if_unnecessary
	(
	    $starting_step "Make vmdir"
	    [ -d "$DATADIR/vmdir" ]
	    $skip_step_if_already_done ; set -e
	    mkdir "$DATADIR/vmdir"
	    # increase default mem to give room for a wakame instance or two
	    echo ': ${KVMMEM:=2048}' >>"$DATADIR/vmdir/datadir.conf"
	) ; prev_cmd_failed

	DATADIR="$DATADIR/vmdir" \
	       "$ORGCODEDIR/ind-steps/kvmsteps/kvm-setup.sh" \
	       "$DATADIR/vmapp-vdc-1box/1box-openvz.netfilter.x86_64.raw.tar.gz"
    ) ; prev_cmd_failed

    (
	$starting_group "Install Jupyter in the OpenVZ 1box image"
	[ -f "$DATADIR/vmdir/1box-openvz-w-jupyter.raw.tar.gz" ]
	$skip_group_if_unnecessary

	# TODO: this guard is awkward.
	[ -x "$DATADIR/vmdir/kvm-boot.sh" ] && \
	    "$DATADIR/vmdir/kvm-boot.sh"

	(
	    $starting_step "Do short set of script lines to install jupyter"
	    [ -x "$DATADIR/vmdir/ssh-to-kvm.sh" ] && {
		[ -f "$DATADIR/vmdir/1box-openvz-w-jupyter.raw.tar.gz" ] || \
		    [ "$("$DATADIR/vmdir/ssh-to-kvm.sh" which jupyter 2>/dev/null)" = "/home/centos/anaconda3/bin/jupyter" ]
	    }
	    $skip_step_if_already_done ; set -e

	    "$DATADIR/vmdir/ssh-to-kvm.sh" <<'EOF'
wget https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda3-2.4.1-Linux-x86_64.sh

chmod +x Anaconda3-2.4.1-Linux-x86_64.sh

./Anaconda3-2.4.1-Linux-x86_64.sh -b

echo 'export PATH="/home/centos/anaconda3/bin:$PATH"' >>.bashrc

export PATH="/home/centos/anaconda3/bin:$PATH"

conda install -y jupyter
EOF
	) ; prev_cmd_failed

	(
	    $starting_step "Install bash_kernel"
	    [ -x "$DATADIR/vmdir/ssh-to-kvm.sh" ] && {
		[ -f "$DATADIR/vmdir/1box-openvz-w-jupyter.raw.tar.gz" ] || \
		    "$DATADIR/vmdir/ssh-to-kvm.sh" '[ -d ./anaconda3/lib/python3.5/site-packages/bash_kernel ]' 2>/dev/null
	    }
	    $skip_step_if_already_done; set -e

	    "$DATADIR/vmdir/ssh-to-kvm.sh" <<'EOF'
pip install bash_kernel
python -m bash_kernel.install
EOF
	) ; prev_cmd_failed

	(
	    $starting_step "Set default password for jupyter, plus other easy initial setup"
	    JCFG="/home/centos/.jupyter/jupyter_notebook_config.py"
	    [ -x "$DATADIR/vmdir/ssh-to-kvm.sh" ] && {
		[ -f "$DATADIR/vmdir/1box-openvz-w-jupyter.raw.tar.gz" ] || \
		    "$DATADIR/vmdir/ssh-to-kvm.sh" grep sha1 "$JCFG" 2>/dev/null 1>&2
	    }
	    $skip_step_if_already_done ; set -e

	    # http://jupyter-notebook.readthedocs.org/en/latest/public_server.html
	    "$DATADIR/vmdir/ssh-to-kvm.sh" <<EOF
set -x
[ -f "$JCFG" ] || jupyter notebook --generate-config

# set default password
saltpass="\$(echo $'from notebook.auth import passwd\nprint(passwd("${JUPYTER_PASSWORD:=warmwinter}"))' | python)"
echo "c.NotebookApp.password = '\$saltpass'" >>"$JCFG"
echo "c.NotebookApp.ip = '*'" >>"$JCFG"

# move jupyter's default directory away from \$HOME
mkdir notebooks
echo "c.NotebookApp.notebook_dir = 'notebooks'" >>"$JCFG"

# autostart on boot
echo "(setsid su - centos -c '/home/centos/anaconda3/bin/jupyter notebook' > /var/log/jupyter.log 2>&1) &" | \
   sudo bash -c "cat >>/etc/rc.local"
EOF
	) ; prev_cmd_failed

	# TODO: this guard is awkward.
	[ -x "$DATADIR/vmdir/kvm-shutdown-via-ssh.sh" ] && \
	    "$DATADIR/vmdir/kvm-shutdown-via-ssh.sh"
	true # needed so the group does not throw an error because of the awkwardness in the previous command
    ) ; prev_cmd_failed

    (
	$starting_step "Make snapshot of image with jupyter installed"
	[ -f "$DATADIR/vmdir/1box-openvz-w-jupyter.raw.tar.gz" ]
	$skip_step_if_already_done ; set -e
	cd "$DATADIR/vmdir/"
	tar czSvf 1box-openvz-w-jupyter.raw.tar.gz 1box-openvz.netfilter.x86_64.raw
    ) ; prev_cmd_failed
)

(
    $starting_step "Expand fresh image from snapshot of image with Jupyter installed"
    [ -f "$DATADIR/vmdir/1box-openvz.netfilter.x86_64.raw" ]
    $skip_step_if_already_done ; set -e
    cd "$DATADIR/vmdir/"
    tar xzSvf 1box-openvz-w-jupyter.raw.tar.gz
) ; prev_cmd_failed

# TODO: this guard is awkward.
[ -x "$DATADIR/vmdir/kvm-boot.sh" ] && \
    "$DATADIR/vmdir/kvm-boot.sh"
