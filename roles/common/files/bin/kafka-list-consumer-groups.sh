#!/usr/bin/env bash

# List active consumer group of Kafka cluster
set -x
docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
