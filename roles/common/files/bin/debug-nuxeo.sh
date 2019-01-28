#!/usr/bin/env bash

NUXEO=${NUXEO:-nuxeo}
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P)"
CONTAINER=${NUXEO} PORT=8787 $SCRIPT_PATH/expose-port.sh
