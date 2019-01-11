#!/usr/bin/env bash
set -x
# tail on audit log stream
docker exec nuxeo /opt/nuxeo/server/bin/stream.sh tail -k -f -l audit --codec avro -schema-store /var/lib/nuxeo/data/avro/ --data-size 5000

