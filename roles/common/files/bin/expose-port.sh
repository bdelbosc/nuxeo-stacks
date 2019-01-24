#!/usr/bin/env bash

# Run a proxy to expose a container port
PORT=27017
CONTAINER=${CONTAINER:-mongo}
set -x
CONTAINER_IP=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $CONTAINER)
docker run --rm --net host alpine/socat TCP-LISTEN:$PORT,fork TCP-CONNECT:$CONTAINER_IP:$PORT
