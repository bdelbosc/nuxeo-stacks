#!/usr/bin/env bash
# Report elastic information as in reporting problem documentation
SERVER="localhost:9200"
set -x
curl "${SERVER}"
curl "${SERVER}/_cat/health?v"
curl "${SERVER}/_cat/nodes?v"
curl "${SERVER}/_cat/indices?v"
curl "${SERVER}/_cluster/stats?pretty"
curl "${SERVER}/_nodes/stats?pretty"
curl "${SERVER}/_cat/health?v"
curl "${SERVER}/_cat/nodes?v"
curl "${SERVER}/_cat/indices?v"
curl "${SERVER}/nuxeo/_settings?pretty"
curl "${SERVER}/nuxeo/_mapping?pretty"
