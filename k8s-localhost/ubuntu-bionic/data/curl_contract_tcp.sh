#!/bin/bash

curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"tenant":"kube","name":"tcp-all","allow-list":[{"protocol":"tcp"}]}' \
  http://localhost:14443/gbp/contracts
