#!/usr/bin/env bash

# Run Confluent KSQL client
set -x
docker exec -it ksql-cli ksql http://ksql-server:8088
