#!/bin/bash

DOCKER_EE_URL=$1
DOCKER_EE_VERSION=$2

sudo apt update
sudo apt-get install -y apt-transport-https ca-certificates curl unzip jq software-properties-common unzip jq

echo $DOCKER_EE_URL
curl -fsSL "${DOCKER_EE_URL}/ubuntu/gpg" | sudo apt-key add -
sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] $DOCKER_EE_URL/ubuntu \
    $(lsb_release -cs) \
    stable-$DOCKER_EE_VERSION"
sudo apt update
sudo apt-get install -y docker-ee docker-ee-cli containerd.io
sudo usermod -aG docker $USER
