#!/usr/bin/env bash
FILENAME=/tmp/nuxeo-record-`date +%Y%m%d-%H%M%S`.jfr
DURATION_S=${DURATION:-60}

docker exec nuxeo jcmd Boot JFR.start duration=${DURATION_S}s filename=${FILENAME}
echo
echo "### Waiting ${DURATION_S}s ..."
sleep ${DURATION_S}
sleep 3
docker cp nuxeo:${FILENAME} ${FILENAME}
echo "### Done you load the following jfr file using jmc:"
echo "${FILENAME}"

