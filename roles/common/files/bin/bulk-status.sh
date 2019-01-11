#!/usr/bin/env bash
# Status of the last submitted Bulk command
set -e
commandId=$(cat /tmp/bulk-command.txt | jq .commandId | tr -d '"')
echo "Status of last command: $commandId"
curl -s -X GET "http://localhost:8080/nuxeo/api/v1/bulk/$commandId"  -u Administrator:Administrator  -H 'content-type: application/json' | jq .
