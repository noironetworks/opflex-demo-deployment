#!/bin/bash

MASTER_IP=1.100.201.11
NUM_NODES=$(cat ./num_nodes)

nextip ()
{
    ip=$1
    iphex=$(printf '%.2X%.2X%.2X%.2X\n' `echo $ip | sed -e 's/\./ /g'`)
    next_iphex=$(printf %.8X `echo $(( 0x$iphex + 1 ))`)
    next_ip=$(printf '%d.%d.%d.%d\n' `echo $next_iphex | sed -r 's/(..)/0x\1 /g'`)
    echo $next_ip
}

curr_ip=$MASTER_IP
for i in $(seq 1 $NUM_NODES); do
    sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@$curr_ip sudo ifconfig enp0s3 up
    echo "External services are now disabled on $curr_ip"
    curr_ip=$(nextip $curr_ip)
done
