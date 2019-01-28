#!/usr/bin/env bash

# Run a proxy to expose the Nuxeo debug port to localhost
PORT=8787
NUXEO=${NUXEO:-nuxeo}
set -x
CONTAINER_IP=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $NUXEO)
docker run --rm --net host alpine/socat TCP-LISTEN:$PORT,fork TCP-CONNECT:$CONTAINER_IP:$PORT
