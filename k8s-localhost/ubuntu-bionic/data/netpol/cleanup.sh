#!/bin/bash
kubectl delete -f ../bbox.yaml -n prod
kubectl delete -f ../bbox.yaml -n dev
kubectl delete deployment web
kubectl delete svc web
kubectl delete namespace prod
kubectl delete namespace dev
