#!/bin/bash

set +e
SVC=$(kubectl get svc | grep web | awk '{print $3}')
echo "Verify connectivity from prod to web"
echo ""
for pod in $(kubectl get pods -n prod | grep Runn | awk '{print $1}')
do
    echo "Pod $pod ..."
    kubectl exec -it $pod -n prod -- nc -zvnw 1 $SVC 80
done

echo ""
echo "Verify connectivity from dev to web"
echo ""
for pod in $(kubectl get pods -n dev | grep Runn | awk '{print $1}')
do
    echo "Pod $pod ..."
    kubectl exec -it $pod -n dev -- nc -zvnw 1 $SVC 80
done
