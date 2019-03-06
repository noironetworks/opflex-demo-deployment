#!/bin/bash

# Provision for Cisco lab environment

HOST_NAME=$(hostname -s)
echo "Provisioning for Cisco lab environment inside node $HOST_NAME"

# Lab proxy
cat <<EOF >>/etc/environment
http_proxy=http://proxy.esl.cisco.com:80
https_proxy=http://proxy.esl.cisco.com:80
no_proxy=localhost,127.0.0.1,172.28.184.8,172.28.184.14,172.28.184.18,vk8s-master,vk8s-node1,vk8s-node2,1.100.201.11,1.100.201.12,1.100.201.13
EOF

# DNS resolution
systemctl disable systemd-resolved.service
systemctl stop systemd-resolved
# Remove the symlink
rm /etc/resolv.conf
cat <<EOF >/etc/resolv.conf
nameserver 172.28.184.18
search noiro.lab
EOF
# Make it immutable
chattr -e /etc/resolv.conf
chattr +i /etc/resolv.conf

# Docker specific stuff
mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF >/etc/systemd/system/docker.service.d/docker-dns.conf
[Service]
Environment="DOCKER_DNS_OPTIONS=\
    --dns 172.28.184.18  \
    --dns-search default.svc.cluster.local --dns-search svc.cluster.local --dns-search noiro.lab  \
    --dns-opt ndots:2 --dns-opt timeout:2 --dns-opt attempts:2  \
"
EOF

cat <<EOF >/etc/systemd/system/docker.service.d/docker-options.conf
[Service]
Environment="DOCKER_OPTS=  --graph=/var/lib/docker --log-opt max-size=50m --log-opt max-file=5 --iptables=false"
EOF

cat <<EOF >/etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://proxy.esl.cisco.com:80" "HTTPS_PROXY=http://proxy.esl.cisco.com:80" "NO_PROXY=localhost,127.0.0.1,172.28.184.8,172.28.184.14,172.28.184.18,vk8s-master,vk8s-node1,vk8s-node2,1.100.201.11,1.100.201.12,1.100.201.13
EOF
