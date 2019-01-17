#!/usr/bin/env bash
NUX_PACKAGES="nuxeo-web-ui nuxeo-jsf-ui nuxeo-platform-importer"

if [[ -e ${NUXEO_HOME}/configured-pkg ]]; then
  echo "# MP already installed"
else
  start=$(date --utc +%Y%m%d_%H%M%SZ)
  echo "# ${start}: Installing MP ${NUX_PACKAGES} ..."
  nuxeoctl mp-install ${NUX_PACKAGES} --relax=false --accept=true
  touch ${NUXEO_HOME}/configured-pkg
  end=$(date --utc +%Y%m%d_%H%M%SZ)
  echo "# ${end}: MP installed"
fi
now=$(date --utc +%Y%m%d_%H%M%SZ)
cp ${NUXEO_CONF} "${NUXEO_DATA}/nuxeo-${now}.conf"
