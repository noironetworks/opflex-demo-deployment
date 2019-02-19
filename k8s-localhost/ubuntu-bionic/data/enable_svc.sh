#!/bin/bash

FIRST_NODE_IP=1.100.201.12
NUM_NODES=$(cat ./num_nodes)

nextip ()
{
    ip=$1
    iphex=$(printf '%.2X%.2X%.2X%.2X\n' `echo $ip | sed -e 's/\./ /g'`)
    next_iphex=$(printf %.8X `echo $(( 0x$iphex + 1 ))`)
    next_ip=$(printf '%d.%d.%d.%d\n' `echo $next_iphex | sed -r 's/(..)/0x\1 /g'`)
    echo $next_ip
}

curr_ip=$FIRST_NODE_IP
for i in $(seq 2 $NUM_NODES); do
    sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@$curr_ip sudo ifconfig enp0s3 down
    echo "External services are now enabled on $curr_ip"
    curr_ip=$(nextip $curr_ip)
done

echo "External services are now enabled on 1.100.201.11"
sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@1.100.201.11 sudo ifconfig enp0s3 down
