#!/usr/bin/env bash
# Nuxeo stacks
#
set -e

get_input() {
  instance_clid=$(whiptail --title "Nuxeo stacks" --inputbox "instance.clid path:" 10 60 "$PWD/instance.clid" 3>&1 1>&2 2>&3)
  if [[ ! -r ${instance_clid} ]]; then
    >&2 echo "ABORT: instance.clid file not found: $instance_clid"
    exit 2
  fi
  data_path=$(whiptail --title "Nuxeo stacks" --inputbox "Data path:" 10 60 "/tmp/my-nuxeo-env" 3>&1 1>&2 2>&3)
  stacks=$(whiptail --title "Nuxeo stacks" \
    --checklist "Choose your stack" 20 60 12 \
    nuxeolatest   "Nuxeo latest" on \
    nuxeo910    "Nuxeo 9.10" off \
    mongo    "MongoDB" on \
    postgres "PostgreSQL" off \
    kafka    "Kafka and Zookeeper" on \
    elastic  "Elasticsearch" on \
    swm      "Stream WorkManager" on \
    redis    "Redis" off \
    monitor  "Graphite and Grafana         " on \
    stream   "Nuxeo Stream monitoring" on \
    kafkahq  "KafkaHQ" on \
    netdata  "Netdata" off \
    3>&1 1>&2 2>&3)
}

parse_input() {
  if [[ ${stacks} == *"nuxeo910"* ]]; then
    nuxeo=True
    nuxeo_version=9.10
  elif [[ ${stacks} == *"nuxeolatest"* ]]; then
    nuxeo=True
    nuxeo_version=latest
  else
    nuxeo=False
    nuxeo_version=latest
  fi
  if [[ ${stacks} == *"mongo"* ]]; then
    mongo=True
  else
    mongo=False
  fi
  if [[ ${stacks} == *"postgres"* ]]; then
    postgres=True
  else
    postgres=False
  fi
  if [[ ${stacks} == *"elastic"* ]]; then
    elastic=True
  else
    elastic=False
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
    -e "env_elastic=$elastic" \
    -e "env_graphite=$graphite env_grafana=$grafana env_kafka=$kafka env_zookeeper=$zookeeper env_kafkahq=$kafkahq" \
    -e "env_stream=$stream env_netdata=$netdata env_swm=$swm"
  set +x
}

bye() {
  echo
  echo "---------------------------------------------------------------"
  echo "# Your Nuxeo stack is ready, next steps:"
  echo "cd ${data_path}"
  echo "docker-compose up"
  echo "http://localhost:8080/nuxeo -> Nuxeo Administrator/Administrator"
  if [[ ${stacks} == *"grafana"* ]]; then
    echo "http://localhost:3000/ -> Grafana admin/admin"
  fi
  if [[ ${stacks} == *"kafkahq"* ]]; then
    echo "http://localhost:3080/ -> KafkaHQ"
  fi
}

# main
get_input
parse_input
venv_init
venv_activate
generate_compose
bye
