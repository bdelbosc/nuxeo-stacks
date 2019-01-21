#!/usr/bin/env bash

# List kafka consumer position for a group
set -x
group_name=${1:-nuxeo-default}
docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group ${group}
