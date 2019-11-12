!#/bin/bash
minikube start --network-plugin=cni
kubectl apply -f aci_deployment.yaml
