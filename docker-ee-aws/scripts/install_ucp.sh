#!/bin/bash

PRIVATE_IP=$1
PRIVATE_DNS=$2
PUBLIC_DNS=$3
PUBLIC_IP=$4
CNI_URL=$5

echo $CNI_URL
sudo docker container run --rm -it --name ucp -v /var/run/docker.sock:/var/run/docker.sock docker/ucp:3.1.4 install --host-address ${PRIVATE_IP} --admin-username admin --admin-password admin123 --san ${PRIVATE_DNS} --san ${PUBLIC_DNS} --san ${PUBLIC_IP} --cni-installer-url  ${CNI_URL}

sudo curl -L https://github.com/containernetworking/cni/releases/download/v0.3.0/cni-v0.3.0.txz -o /opt/cni/bin/cni-v0.3.0.txz
sudo tar Jxvf /opt/cni/bin/cni-v0.3.0.txz -C /opt/cni/bin
