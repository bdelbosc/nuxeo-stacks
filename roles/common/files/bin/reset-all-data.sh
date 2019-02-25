#!/usr/bin/env bash

# Delete all env data
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P)"
DATA_PATH=$(readlink -f "$SCRIPT_PATH/../data")
if [[ ! -e $DATA_PATH ]]; then
  echo "Data path: $DATA_PATH not found"
  exit 1
fi
read -p "Delete all the data in $DATA_PATH, Are you sure? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  exit 1
fi
set -x
sudo rm -rf "$DATA_PATH/kafka/data/"*
sudo rm -rf "$DATA_PATH/kafka/log/"*
sudo rm -rf "$DATA_PATH/zookeeper/data/"*
sudo rm -rf "$DATA_PATH/zookeeper/log/"*
sudo rm -rf "$DATA_PATH/elastic/"*
# keep instance.clid remove only directories
sudo rm -rf "$DATA_PATH/nuxeo"*"/data/"*/
sudo rm -rf "$DATA_PATH/nuxeo"*"/data/"*.conf
sudo rm -rf "$DATA_PATH/nuxeo"*"/data/bundles.ids"
sudo rm -rf "$DATA_PATH/nuxeo-binaries/"*
sudo rm -rf "$DATA_PATH/mongo/"*
sudo rm -rf "$DATA_PATH/postgres/"*
sudo rm -rf "$DATA_PATH/graphite/"*
sudo rm -rf "$DATA_PATH/grafana/"*
sudo rm -rf "$DATA_PATH/redis/"*
sudo rm -rf "$DATA_PATH/prometheus/"*

