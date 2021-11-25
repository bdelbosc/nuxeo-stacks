#!/usr/bin/env bash

# Delete all env data
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P)"
DATA_PATH=$(readlink -f "$SCRIPT_PATH/../data")
set -x
rm -rf "$DATA_PATH/nuxeo"*"/packages/"*
rm -rf "$DATA_PATH/nuxeo"*"/packages/.packages"*
