#!/usr/bin/env bash

SERVER_URL=${SERVER_URL:-http://nuxeo.docker.localhost}
set -e
set -x
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P)"
curl -X GET -u Administrator:Administrator "${SERVER_URL}/nuxeo/api/v1/management/stream/scale" | jq .

