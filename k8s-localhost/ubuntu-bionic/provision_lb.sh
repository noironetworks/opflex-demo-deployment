#!/bin/bash

MASTER_IP=$1
NUM_NODES=$2
SERVICE_SUBNET=10.3.0.0/16

HOST_NAME=$(hostname -s)

echo "Executing inside node $HOST_NAME"

sudo sysctl -w net.ipv4.ip_forward=1
sudo echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sudo sysctl -w net.ipv4.fib_multipath_hash_policy=1
sudo echo "net.ipv4.fib_multipath_hash_policy=1" >> /etc/sysctl.conf 
sudo sysctl -w net.ipv4.fib_multipath_use_neigh=1
sudo echo "net.ipv4.fib_multipath_use_neigh=1" >> /etc/sysctl.conf 
echo $NUM_NODES > $HOME/data/num_nodes

nextip ()
{
    ip=$1
    iphex=$(printf '%.2X%.2X%.2X%.2X\n' `echo $ip | sed -e 's/\./ /g'`)
    next_iphex=$(printf %.8X `echo $(( 0x$iphex + 1 ))`)
    next_ip=$(printf '%d.%d.%d.%d\n' `echo $next_iphex | sed -r 's/(..)/0x\1 /g'`)
    echo $next_ip
}

CMD="ip route add $SERVICE_SUBNET "
curr_ip=$MASTER_IP
for i in $(seq 1 $NUM_NODES); do
    CMD="$CMD nexthop via $curr_ip "
    curr_ip=$(nextip $curr_ip)
done

echo $CMD
eval $CMD

echo "Done provisioning $HOST_NAME"
