#!/usr/bin/env bash

# Reindex using the Bulk Action Service
DOMAIN=${DOMAIN:-localhost}
SERVER_URL=${SERVER_URL:-http://nuxeo.docker.$DOMAIN}
set -e
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P)"
curl -s -X POST "${SERVER_URL}/nuxeo/site/automation/Elasticsearch.BulkIndex" -u Administrator:Administrator -H 'content-type: application/json+nxrequest' -d '{"params":{},"context":{}}' | tee /tmp/bulk-command.txt | jq .
${SCRIPT_PATH}/bulk-status.sh

