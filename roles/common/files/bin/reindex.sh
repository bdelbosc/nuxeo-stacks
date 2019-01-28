#!/usr/bin/env bash

# Reindex the repository using the WorkManager
SERVER_URL=${SERVER_URL:-http://nuxeo.docker.localhost}
set -e
set -x
curl -X POST "$SERVER_URL/nuxeo/site/automation/Elasticsearch.Index" -u Administrator:Administrator -H 'content-type: application/json+nxrequest' -d '{"params":{},"context":{}}'
curl -X POST "$SERVER_URL/nuxeo/site/automation/Elasticsearch.WaitForIndexing" -u Administrator:Administrator -H 'content-type: application/json+nxrequest' -d '{"params":{"timeoutSecond": "3600", "refresh": "true"},"context":{}}'


