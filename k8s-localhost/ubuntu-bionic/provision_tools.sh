#!/bin/bash

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4052245BD4284CDD
echo "deb https://repo.iovisor.org/apt/$(lsb_release -cs) $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/iovisor.list

apt-get update

apt-get install -y linux-tools-$(uname -r) linux-tools-generic
apt-get install -y bison build-essential cmake flex git libedit-dev python zlib1g-dev libelf-dev libllvm4.0 llvm-dev libclang-dev git
apt-get install -y bcc-tools libbcc-examples linux-headers-$(uname -r)

#git clone https://github.com/iovisor/bcc.git

#mkdir bcc/build
#cd bcc/build
#cmake .. -DCMAKE_INSTALL_PREFIX=/usr
#make -j 2
#make install
