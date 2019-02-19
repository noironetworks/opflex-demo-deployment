#!/bin/bash

sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@1.100.201.12 sudo ifconfig enp0s3 down

echo "Node Port is now enabled on 1.100.201.12"
echo "Use kubectl get svc to get the nodeport port"
echo "and access http://1.100.201.12:<port>"
