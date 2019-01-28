#!/usr/bin/env bash

SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P)"
ESYNC_VERSION=3.0.1-SNAPSHOT
ESYNC_JAR=~/.m2/repository/org/nuxeo/tools/nuxeo-esync/${ESYNC_VERSION}/nuxeo-esync-${ESYNC_VERSION}-capsule-full.jar
if [[ ! -f ${ESYNC_JAR} ]]; then
  mvn -DgroupId=org.nuxeo.tools -DartifactId=nuxeo-esync -Dversion=${ESYNC_VERSION} -Dclassifier=capsule-full -DrepoUrl=http://maven.nuxeo.org/nexus/content/groups/public-snapshot dependency:get
fi
set -x
java -jar ${ESYNC_JAR} ${SCRIPT_PATH}/esync.conf
