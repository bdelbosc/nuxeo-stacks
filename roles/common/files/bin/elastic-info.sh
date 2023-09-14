#!/usr/bin/env bash

# Report elastic information as in reporting problem documentation
DOMAIN=${DOMAIN:-localhost}
SERVER=${SERVER:-http://elastic.docker.$DOMAIN}
set -x
echo "# Elastic -----------"
curl "${SERVER}"
echo "# Health ------------"
curl "${SERVER}/_cat/health?v"
echo "# Nodes -------------"
curl "${SERVER}/_cat/nodes?v"
echo "# Indices -----------"
curl "${SERVER}/_cat/indices?v"
echo "# Cluster stats -----"
curl "${SERVER}/_cluster/stats?pretty"
echo "# Nodes stats -------"
curl "${SERVER}/_nodes/stats?pretty"
echo "# nuxeo settings ----"
curl "${SERVER}/nuxeo/_settings?pretty"
echo "# nuxeo mapping  ----"
curl "${SERVER}/nuxeo/_mapping?pretty"
echo "# audit settings ----"
curl "${SERVER}/nuxeo-audit/_settings?pretty"
echo "# audit mapping -----"
curl "${SERVER}/nuxeo-audit/_mapping?pretty"
