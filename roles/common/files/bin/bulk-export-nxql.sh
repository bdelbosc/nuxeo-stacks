#!/usr/bin/env bash

# Performs a CSV export of the entire repository
DOMAIN=${DOMAIN:-localhost}
SERVER_URL=${SERVER_URL:-http://nuxeo.docker.$DOMAIN}
NXQL=${NXQL:-SELECT * FROM Document WHERE ecm:isProxy = 0 AND ecm:isVersion = 0 AND ecm:isTrashed = 0}
echo "# $NXQL"
set -e
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P)"
set -x
curl -XPOST "$SERVER_URL/nuxeo/api/v1/search/bulk/csvExport" --get --data-urlencode "query=$NXQL" -u Administrator:Administrator -H 'Content-Type: application/json' --compressed | tee /tmp/bulk-command.txt | jq .
${SCRIPT_PATH}/bulk-status.sh
