#!/bin/bash

curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"tenant":"kube","name":"any", "allow-list":[{"protocol":"","ports":{}}]}' \
  http://localhost:14443/gbp/contracts
