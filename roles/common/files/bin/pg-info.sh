#!/usr/bin/env bash

# Report PostgreSQL information as in reporting problem documentation
set -e
set -x
if [[ ! -f /tmp/pgconf.sql ]]; then
  wget --no-check-certificate https://gist.github.com/bdelbosc/5507796/raw/dump-nuxeo-postgres-config.sql -O /tmp/pgconf.sql
fi
docker cp /tmp/pgconf.sql postgres:/tmp/
docker exec postgres psql postgresql://nuxeo:nuxeo@postgres:5432/nuxeo -f /tmp/pgconf.sql
docker exec postgres cat /tmp/pgconf.txt
