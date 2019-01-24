#!/usr/bin/env bash

# List kafka topics
set -x
docker exec kafka /opt/kafka/bin/kafka-topics.sh --zookeeper zookeeper:2181 --describe
