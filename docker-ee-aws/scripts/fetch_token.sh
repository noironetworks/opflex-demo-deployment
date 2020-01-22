#!/bin/bash

set -e

function parse_input() {
  eval "$(jq -r '@sh "KEY_PAIR=\(.key_pair) PUBLIC_IP=\(.public_ip)"')"
  if [[ "${KEY_PAIR}" == null ]];
  then
    echo "key_pair not set"
    exit 1;
  fi
  if [[ "${PUBLIC_IP}" == null ]];
  then
    echo "public_ip not found"
    exit 1;
  fi
}

parse_input

WRKR_TKN=$(ssh -i ${KEY_PAIR} -o StrictHostKeyChecking=no ubuntu@${PUBLIC_IP} docker swarm join-token worker -q)

jq -n --arg worker_token "$WRKR_TKN" '{"worker_token":$worker_token}'
