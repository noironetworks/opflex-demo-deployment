#!/bin/bash
kubectl run web --image=nginx \
    --labels=app=web --expose --port 80

kubectl create namespace dev
kubectl label namespace/dev purpose=testing
kubectl create namespace prod
kubectl label namespace/prod purpose=production

kubectl apply -f ../bbox.yaml -n prod
kubectl apply -f ../bbox.yaml -n dev
