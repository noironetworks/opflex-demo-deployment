#!/bin/bash

curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"tenant":"kube","name":"kubernetes|kube-epgB", "consumed-contracts":["tcp-all"], "provided-contracts":["tcp-all"]}' \
  http://localhost:14443/gbp/epgs
