#!/usr/bin/env bash
# Reindex the repository using the WorkManager
set -e
set -x
curl -X POST 'http://localhost:8080/nuxeo/site/automation/Elasticsearch.Index' -u Administrator:Administrator -H 'content-type: application/json+nxrequest' -d '{"params":{},"context":{}}'
curl -X POST 'http://localhost:8080/nuxeo/site/automation/Elasticsearch.WaitForIndexing' -u Administrator:Administrator -H 'content-type: application/json+nxrequest' -d '{"params":{"timeoutSecond": "3600", "refresh": "true"},"context":{}}'


