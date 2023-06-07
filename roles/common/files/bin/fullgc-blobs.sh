#!/usr/bin/env bash

SERVER_URL=${SERVER_URL:-http://nuxeo.docker.localhost}
set -e
set -x
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P)"
curl -X DELETE -u Administrator:Administrator "${SERVER_URL}/nuxeo/api/v1/management/blobs/orphaned" | tee /tmp/bulk-command.txt | jq .
${SCRIPT_PATH}/bulk-status.sh

