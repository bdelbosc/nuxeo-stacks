#!/usr/bin/env bash
# Run redis-cli client
set -x
docker exec -it redis redis-cli
