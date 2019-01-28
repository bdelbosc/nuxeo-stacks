#!/usr/bin/env bash

# Status of the last submitted Bulk command
set -e
SERVER_URL=${SERVER_URL:-http://nuxeo.docker.localhost}
commandId=$(cat /tmp/bulk-command.txt | jq .commandId | tr -d '"')
echo "Status of last command: $commandId"
curl -s -X GET "$SERVER_URL/nuxeo/api/v1/bulk/$commandId" -u Administrator:Administrator -H 'content-type: application/json' | jq .
