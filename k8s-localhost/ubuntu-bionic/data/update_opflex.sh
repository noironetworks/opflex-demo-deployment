#!/bin/bash
# ./update_opflex.sh <policyfile>

SRC=$1
DST=/usr/local/etc/opflex-server/policy.json

[ -z "$SRC" ] && SRC=./policy.json

for i in `kubectl get pods --all-namespaces -o \
    custom-columns=":metadata.name" | grep aci-containers-host`; \
    do \
    kubectl cp $SRC kube-system/$i:$DST -c opflex-server; \
    done
