#!/usr/bin/env bash
SCRIPT_PATH="$(cd "$(dirname "$0")/.."; pwd -P)"

TEST_PATH="/tmp/nuxeo-stacks-tests"
TEST_MODE=${TEST_MODE:-FAST}

set -e
set -x
rm -rf "$TEST_PATH"
mkdir -p "$TEST_PATH"

${SCRIPT_PATH}/nuxeoenv.sh -t ${TEST_MODE} -i "$SCRIPT_PATH/instance.clid" -d "$TEST_PATH/NL1" -c no -n nuxeolatest -b none -s none
docker-compose -f "$TEST_PATH/NL1/docker-compose.yml" config

${SCRIPT_PATH}/nuxeoenv.sh -t ${TEST_MODE} -i "$SCRIPT_PATH/instance.clid" -d "$TEST_PATH/NL1MER" -c no -n nuxeolatest -b mongo -s '"elastic" "redis"'
docker-compose -f "$TEST_PATH/NL1MER/docker-compose.yml" config

${SCRIPT_PATH}/nuxeoenv.sh -t ${TEST_MODE} -i "$SCRIPT_PATH/instance.clid" -d "$TEST_PATH/N91PEK" -c no -n nuxeo910 -b postgres -s '"elastic" "kafka"'
docker-compose -f "$TEST_PATH/N91PEK/docker-compose.yml" config

${SCRIPT_PATH}/nuxeoenv.sh -t ${TEST_MODE} -i "$SCRIPT_PATH/instance.clid" -d "$TEST_PATH/NL3MEKRSMSKKN" -c 3 -n nuxeolatest -b mongo -s '"elastic" "kafka" "redis" "swm" "monitor" "stream" "kibana" "kafkahq" "netdata"'
docker-compose -f "$TEST_PATH/NL3MEKRSMSKKN/docker-compose.yml" config
