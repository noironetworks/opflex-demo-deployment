#!/bin/bash

IP=`ip -4 addr show dev enp0s8 | grep inet | awk '{print $2}' | cut -f1 -d/`
HOST_NAME=$(hostname -s)

echo "Executing inside node $HOST_NAME"

apt-get update
echo "Installing sshpass"
apt-get install -y sshpass

echo "Installing docker 18.06"
apt-get install -y docker.io
systemctl enable docker.service

echo "Allow vagrant user to run docker commands"
usermod -aG docker vagrant

echo "Installing kubeadm"
apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo "Turn off swap"
swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "Setting kubelet node ip"
sed -i "/^[^#]*KUBELET_EXTRA_ARGS=/c\KUBELET_EXTRA_ARGS=--node-ip=$IP" /etc/default/kubelet
systemctl restart kubelet

echo "Setup node for clear text ssh"
sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
service sshd restart

echo "Done provisioning $HOST_NAME"
