#!/usr/bin/env bash

# Status of the last submitted Bulk command
set -e
DOMAIN=${DOMAIN:-localhost}
SERVER_URL=${SERVER_URL:-http://nuxeo.docker.$DOMAIN}
commandId=$(cat /tmp/bulk-command.txt | jq .commandId | tr -d '"')
echo "Status of last command: $commandId"
curl -s -X GET "$SERVER_URL/nuxeo/api/v1/bulk/$commandId" -u Administrator:Administrator -H 'content-type: application/json' | jq .
