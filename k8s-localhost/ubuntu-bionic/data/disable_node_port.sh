#!/bin/bash

sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@1.100.201.12 sudo ifconfig enp0s3 up
echo "NodePort disabled on 1.100.201.12"
