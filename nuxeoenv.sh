#!/usr/bin/env bash

# Nuxeo stacks
#
set -e

usage() { echo "Usage: $0 [-i clid -d data -n nuxeo -b backend -s stack" 1>&2;
  exit 1; }

get_opts() {
  while getopts ":i:d:n:b:s:" o; do
    case "${o}" in
      i)
        instance_clid=${OPTARG}
      ;;
      d)
        data_path=${OPTARG}
      ;;
      n)
        nuxeo_dist=${OPTARG}
      ;;
      b)
        backend=${OPTARG}
      ;;
      s)
        stacks=${OPTARG}
        echo "stacks: $stacks"
      ;;
      *)
        usage
      ;;
    esac
  done
}

get_input() {
  if [[ -z "${instance_clid}" ]]; then
    instance_clid=$(whiptail --title "Nuxeo stacks" --inputbox "Enter path of a valid Nuxeo instance.clid file:" 10 60 "$PWD/instance.clid" 3>&1 1>&2 2>&3)
  fi
  if [[ ! -r ${instance_clid} ]]; then
    >&2 echo "ABORT: instance.clid file not found: $instance_clid"
    exit 2
  fi
  if [[ -z "${data_path}" ]]; then
    data_path=$(whiptail --title "Nuxeo stacks" --inputbox "Enter path to the Nuxeo environment to create:" 10 60 "/tmp/my-nuxeo-env" 3>&1 1>&2 2>&3)
  fi
  if [[ -x "$(command -v realpath)" ]]; then
    data_path=`realpath -m ${data_path}`
  fi
  if [[ -z "${nuxeo_dist}" ]]; then
    nuxeo_dist=$(whiptail --title "Nuxeo stacks" --radiolist "Choose a Nuxeo distribution:" 10 60 3 \
 nuxeolatest "Nuxeo latest                  " on \
 nuxeo910 "Nuxeo 9.10" off \
 none "None" off \
 3>&1 1>&2 2>&3)
  fi
  if [[ -z "${backend}" ]]; then
    backend=$(whiptail --title "Nuxeo stacks" --radiolist "Choose a Nuxeo backend:" 10 60 3 \
 mongo "MongoDB                          " on \
 postgres "PostgreSQL" off \
 3>&1 1>&2 2>&3)
  fi
  if [[ -z "${stacks}" ]]; then
    stacks=$(whiptail --title "Nuxeo stacks" --checklist "Compose your stack:" 18 60 10 \
 elastic "Elasticsearch" on \
 kafka "Kafka and Zookeeper" on \
 redis "Redis" off \
 swm "Nuxeo Stream WorkManager" on \
 monitor "Nuxeo Grafana dashboard" on \
 stream "Nuxeo Stream monitoring" on \
 kibana "Elastic GUI" on \
 kafkahq "Kafka GUI" on \
 netdata "Netdata Real-time monitoring" off \
 3>&1 1>&2 2>&3)
  fi
  COMMAND="${0} -i \"${instance_clid}\" -d \"${data_path}\" -n ${nuxeo_dist} -b ${backend} -s "${stacks@Q}""
}

parse_input() {
  if [[ ${nuxeo_dist} == *"nuxeolatest"* ]]; then
    nuxeo=True
    nuxeo_version=latest
  elif [[ ${nuxeo_dist} == *"nuxeo910"* ]]; then
    nuxeo=True
    nuxeo_version=9.10
  else
    nuxeo=False
    nuxeo_version=latest
  fi
  if [[ ${backend} == *"mongo"* ]]; then
    mongo=True
    postgres=False
  elif [[ ${backend} == *"postgres"* ]]; then
    mongo=False
    postgres=True
  else
    mongo=False
    postgres=False
  fi
  if [[ ${stacks} == *"elastic"* ]]; then
    elastic=True
    if [[ ${stacks} == *"kibana"* ]]; then
      kibana=True
    else
      kibana=False
    fi
  else
    elastic=False
    kibana=False
  fi
  if [[ ${stacks} == *"redis"* ]]; then
    redis=True
  else
    redis=False
  fi
  if [[ ${stacks} == *"kafka"* ]]; then
    kafka=True
    zookeeper=True
    if [[ ${stacks} == *"kafkahq"* ]]; then
      kafkahq=True
    else
      kafkahq=False
    fi
  else
    kafka=False
    zookeeper=False
    kafkahq=False
  fi
  if [[ ${stacks} == *"stream"* ]]; then
    stream=True
  else
    stream=False
  fi
  if [[ ${stacks} == *"swm"* ]]; then
    swm=True
  else
    swm=False
  fi
  if [[ ${stacks} == *"monitor"* ]]; then
    graphite=True
    grafana=True
  else
    graphite=False
    grafana=False
  fi
  if [[ ${stacks} == *"netdata"* ]]; then
    netdata=True
  else
    netdata=False
  fi
}

venv_init() {
  if [[ ! -r ./venv/ ]]; then
    virtualenv ./venv
    venv_activate
    pip install ansible
  fi
}

venv_activate() {
  source ./venv/bin/activate
}

generate_compose() {
  set -x
  ansible-playbook site.yml -i ./hosts -e "env_data_path=$data_path env_instance_clid=$instance_clid" \
 -e "env_nuxeo=$nuxeo env_nuxeo_version=$nuxeo_version" \
 -e "env_mongo=$mongo env_postgres=$postgres env_redis=$redis" \
 -e "env_elastic=$elastic env_kibana=$kibana" \
 -e "env_graphite=$graphite env_grafana=$grafana env_kafka=$kafka env_zookeeper=$zookeeper env_kafkahq=$kafkahq" \
 -e "env_stream=$stream env_netdata=$netdata env_swm=$swm"
  set +x
}

bye() {
  echo
  echo "---------------------------------------------------------------"
  echo "# Nuxeo Stack generated with:"
  echo ${COMMAND}
  echo "# Next steps:"
  echo "cd ${data_path}"
  echo "docker-compose up"
  echo "http://localhost:8080/nuxeo -> Nuxeo Administrator/Administrator"
  if [[ ${stacks} == *"monitor"* ]]; then
    echo "http://localhost:3000/ -> Grafana admin/admin"
  fi
  if [[ ${stacks} == *"kafkahq"* ]]; then
    echo "http://localhost:3080/ -> KafkaHQ"
  fi
}

# main
get_opts "$@"
get_input
parse_input
venv_init
venv_activate
generate_compose
bye
