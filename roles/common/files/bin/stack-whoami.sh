#!/usr/bin/env bash

# Search the docker-compose file that is running
check_path() {
  if [[ -f "$1/docker-compose.yml" ]]; then
    echo "$1"
    exit 0
  fi
}

fail() {
  echo $1 1>&2
  exit 1
}

# Try to find the path from a mounted volume used by Nuxeo
(docker ps | grep -q nuxeo) || fail "ERROR: No Nuxeo Stack found"
set -e
path=`docker inspect -f '{{ (index .Mounts 0).Source }}' nuxeo`
# volumes are unordered but the compose file must in the parent or grand parent dir
cd `dirname $path`
cd ..
check_path `pwd`
cd ..
check_path `pwd`

# not found give some clue
project=`docker inspect -f '{{ index .Config.Labels "com.docker.compose.project" }}' nuxeo`
fail "ERROR: Cannot find the docker-compose.yml for $project, should be around $path ?"
