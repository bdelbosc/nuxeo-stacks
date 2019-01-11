#!/usr/bin/env bash
set -e
NUXEO_DATA=${NUXEO_DATA:-/var/lib/nuxeo/data}
NUXEO_LOG=${NUXEO_LOG:-/var/log/nuxeo}

cat /etc/nuxeo/nuxeo.conf.template > ${NUXEO_CONF}
cat << EOF >> $NUXEO_CONF
nuxeo.log.dir=$NUXEO_LOG
nuxeo.pid.dir=/var/run/nuxeo
nuxeo.data.dir=$NUXEO_DATA
EOF

if [[ -f /docker-entrypoint-initnuxeo.d/nuxeo.conf ]]; then
  cat /docker-entrypoint-initnuxeo.d/nuxeo.conf >> ${NUXEO_CONF}
fi
echo "### Generate nuxeo configuration"
nuxeoctl configure
exec "$@"



