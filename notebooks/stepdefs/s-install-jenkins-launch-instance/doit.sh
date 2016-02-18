#!/bin/bash

thescript="$(cat <<EEE
cat <<EOS >vifs.json
{
 "eth0":{"network":"nw-demo1","security_groups":"sg-cicddemo"}
}
EOS

mussel instance create --cpu-cores 2 --hypervisor openvz \
    --image-id wmi-centos1d64 --memory-size 2048 \
    --ssh-key-id ssh-cicddemo --vifs vifs.json --display-name centos
EEE
)"

echo "Now executing the following script to do this step:"
echo "$thescript"
echo
echo "Output follows:"

bash <<<"$thescript"

echo "## End of Output ##"
