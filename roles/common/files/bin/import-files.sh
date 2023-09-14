#!/usr/bin/env bash

# Import using the nuxeo-importer-stream addon
# https://github.com/nuxeo/nuxeo-platform-importer/tree/master/nuxeo-importer-stream
set -x
set -e
DOMAIN=${DOMAIN:-localhost}
SERVER_URL=${SERVER_URL:-http://nuxeo.docker.$DOMAIN}
LIST_FILE=$1
BASE_PATH="$(dirname $1)"

shift
ROOT_FOLDER=/default-domain/workspaces
NB_DOCS=1000
NB_THREADS=2
PREFIX=nx2

echo "# 1/4 Produce blob messages"
time curl -fX POST "$SERVER_URL/nuxeo/site/automation/StreamImporter.runFileBlobProducers" -u Administrator:Administrator -H 'content-type: application/json+nxrequest' \
 -d $'{"params":{
    "nbBlobs": 0,
    "nbThreads": 1,
    "listFile": "'${LIST_FILE}'",
    "basePath": "'${BASE_PATH}'",
    "logName": "'${PREFIX}'-blobs"
    }}'

echo "# 2/4 Import blob into binary store and produce blobs-infos message"
time curl -fX POST "$SERVER_URL/nuxeo/site/automation/StreamImporter.runBlobConsumers" -u Administrator:Administrator -H 'content-type: application/json+nxrequest' \
 -d $'{"params":{
    "blobProviderName": "",
    "logBlobInfo": "'${PREFIX}'-blobs-info",
    "logName": "'${PREFIX}'-blobs"
    }}'

echo "# 3/4 Produce document messages"
time curl -fX POST "$SERVER_URL/nuxeo/site/automation/StreamImporter.runRandomDocumentProducers" -u Administrator:Administrator -H 'content-type: application/json+nxrequest' \
 -d $'{"params":{
    "nbDocuments": '${NB_DOCS}',
    "nbThreads": '${NB_THREADS}',
    "logBlobInfo": "'${PREFIX}'-blobs-info",
    "logName": "'${PREFIX}'-docs",
    "countFolderAsDocument": false
    }}'

echo "# 4/4 Create Nuxeo documents"
time curl -fX POST "$SERVER_URL/nuxeo/site/automation/StreamImporter.runDocumentConsumers" -u Administrator:Administrator -H 'content-type: application/json' \
 -d $'{"params":{
      "rootFolder": "'${ROOT_FOLDER}'",
      "logName": "'${PREFIX}'-docs"
      }}'

