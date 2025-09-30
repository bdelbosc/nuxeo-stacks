#!/usr/bin/env bash

# Run mongo client
set -x
docker exec -it mongo mongosh localhost/nuxeo

