#!/usr/bin/env bash

# Run psql client
set -x
docker exec -it postgres psql postgresql://nuxeo:nuxeo@postgres:5432/nuxeo
