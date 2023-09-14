#!/usr/bin/env bash
PLANT_URL=https://netcologne.dl.sourceforge.net/project/plantuml/plantuml.jar
PLANT_JAR=~/Downloads/plantuml.jar
DOMAIN=${DOMAIN:-localhost}
SERVER_URL=${SERVER_URL:-http://nuxeo.docker.$DOMAIN}

function install_plant() {
  if [[ ! -e ${PLANT_JAR} ]]; then
    echo "### Installing plantuml jar..."
    wget -O "${PLANT_JAR}" "${PLANT_URL}"
  fi
}

install_plant

set -x
curl -u Administrator:Administrator ${SERVER_URL}/nuxeo/api/v1/management/stream/puml/ > /tmp/streams.puml

java  -DPLANTUML_LIMIT_SIZE=16384  -jar ${PLANT_JAR} /tmp/streams.puml -tsvg
x-www-browser /tmp/streams.svg
