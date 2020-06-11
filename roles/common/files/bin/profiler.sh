#!/usr/bin/env bash
set -e
DURATION=${DURATION:-30}
ASYNC_PROFILER=https://github.com/jvm-profiling-tools/async-profiler/releases/download/v1.7/async-profiler-1.7-linux-x64.tar.gz
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P)"
DATA_PATH=$(readlink -f "$SCRIPT_PATH/../data")
DATA_PROFILER="${DATA_PATH}/profiler"
TIMESTAMP=`date +%Y%m%d-%H%M%S`
MODE=${MODE:-cpu}
SVG_FILE=flame-${MODE}-${TIMESTAMP}.svg


if [[ ! -e ${DATA_PROFILER} ]]; then
  echo "Data profiler path: $DATA_PROFILER not found"
  exit 1
fi

# Report elastic information as in reporting problem documentation

function install_profiler() {
  if [[ ! -e ${DATA_PROFILER}/profiler.sh ]]; then
    echo "### Installing async profiler..."
    wget -O ${DATA_PROFILER}/async-profiler.tar.gz ${ASYNC_PROFILER} &&\
        cd ${DATA_PROFILER}/ &&\
        tar -xvzf async-profiler.tar.gz &&\
        rm -f ${DATA_PROFILER}/async-profiler.tar.gz
  fi
  # this requires nuxeo to run as privileged
  docker exec -u root nuxeo sh -c "echo 0 > /proc/sys/kernel/kptr_restrict"
  #docker exec nuxeo cat /proc/sys/kernel/kptr_restrict
  docker exec -u root nuxeo sh -c "echo 1 > /proc/sys/kernel/perf_event_paranoid"
  #docker exec nuxeo cat /proc/sys/kernel/perf_event_paranoid
}

function run_profiler() {
  echo "### Profiling ${MODE} for ${DURATION}s ..."
  option=""
  if [[ "${MODE}" == "cpu" ]]; then
    option=""
  elif [[ "${MODE}" == "off-cpu" ]]; then
    option="-e wall -t -I work/* -I bulk/* -I http-nio-* -I retention/* -I audit/* -I stream/*"
  elif [[ "${MODE}" == "mem" ]]; then
    option="-e alloc"
  elif [[ "${MODE}" == "lock" ]]; then
    option="-e lock"
  fi
  title=$'"Nuxeo '${MODE}' '${TIMESTAMP}' '${DURATION}'s"'
  set -x
  docker exec -it -u root nuxeo /profiler/profiler.sh ${option} -d ${DURATION} --title "${title}" -f /profiler/${SVG_FILE} jps
  set +x
}

function view_file () {
  svg_path=${DATA_PROFILER}/${SVG_FILE}
  if [[ -e ${svg_path} ]]; then
    echo "### Opening $svg_path"
    if which x-www-browser >/dev/null; then
      x-www-browser "file://$svg_path"&
    else
      # osx
      open "file://$svg_path"
    fi
  else
    echo "### SVG not found." >&2
    exit 1
  fi
}

# main
install_profiler
run_profiler
view_file
