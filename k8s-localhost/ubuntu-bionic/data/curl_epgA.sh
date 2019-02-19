#!/bin/bash

curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"tenant":"kube","name":"kubernetes|kube-epgA", "consumed-contracts":["all-all"], "provided-contracts":["all-all"]}' \
  http://localhost:14443/gbp/epgs
