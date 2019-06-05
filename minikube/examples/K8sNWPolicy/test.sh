#!/bin/bash

set +e
SVC=hostnames-svc.default
echo "Verify connectivity from prod to web"
echo ""
for pod in $(kubectl get pods -n prod | grep Runn | awk '{print $1}')
do
    echo "Pod $pod ..."
    kubectl exec -it $pod -n prod -- nc -zvw 1 $SVC 80
done

echo ""
echo "Verify connectivity from dev to web"
echo ""
for pod in $(kubectl get pods -n dev | grep Runn | awk '{print $1}')
do
    echo "Pod $pod ..."
    kubectl exec -it $pod -n dev -- nc -zvw 1 $SVC 80
done
