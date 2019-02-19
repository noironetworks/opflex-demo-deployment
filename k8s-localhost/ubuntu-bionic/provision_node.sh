#!/bin/bash

MASTER_IP=$1

HOST_NAME=$(hostname -s)

echo "Executing inside node $HOST_NAME"

echo "Copy kubeadm join command from master"
sshpass -p "vagrant" scp -o StrictHostKeyChecking=no vagrant@$MASTER_IP:/bin/kubeadm_join.sh .

echo "Run kubeadm join"
bash ./kubeadm_join.sh

echo "Done provisioning $HOST_NAME"
