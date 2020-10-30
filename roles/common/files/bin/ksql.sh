#!/usr/bin/env bash

# Run Confluent KSQL client
set -x
docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
