#!/usr/bin/env bash

# Stop the running stack
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P)"
set -e
root=`${SCRIPT_PATH}/stack-whoami.sh`
set -x
docker-compose -f $root/docker-compose.yml down --volume
