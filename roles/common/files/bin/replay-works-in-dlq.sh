#!/usr/bin/env bash

# Execute the Work in failure stored in the DLQ
DOMAIN=${DOMAIN:-localhost}
SERVER_URL=${SERVER_URL:-http://nuxeo.docker.$DOMAIN}
set -e
set -x
curl -X POST "$SERVER_URL/nuxeo/site/automation/WorkManager.RunWorkInFailure" -u Administrator:Administrator -H 'content-type: application/json+nxrequest' -d '{"params":{},"context":{}}'

