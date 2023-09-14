#!/usr/bin/env bash

# Run an NXQL query
DOMAIN=${DOMAIN:-localhost}
SERVER_URL=${SERVER_URL:-http://nuxeo.docker.$DOMAIN}
NXQL=${NXQL:-SELECT * FROM Document WHERE ecm:mixinType != 'HiddenInNavigation' AND ecm:isProxy = 0 AND ecm:isVersion = 0 AND ecm:isTrashed = 0}
echo "# $NXQL"
set -e
set -x
time curl -s -u Administrator:Administrator --get --data-urlencode "query=$NXQL" "$SERVER_URL/nuxeo/api/v1/query?pageSize=1&currentPageIndex=0" | jq .
