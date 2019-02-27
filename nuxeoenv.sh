#!/usr/bin/env bash

# Nuxeo stacks
#
set -e
PLAYBOOK_OPTS=""

usage() { echo "Usage: $0 [-i clid -d data -n nuxeo -b backend -s stack" 1>&2;
  exit 1; }

get_opts() {
  while getopts ":i:d:n:b:s:c:t:" o; do
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
      ;;
      c)
        nuxeo_cluster=${OPTARG}
      ;;
      t)
        if [[ "FAST" == "$OPTARG" ]]; then
          PLAYBOOK_OPTS="$PLAYBOOK_OPTS --tags test"
        fi
      ;;
      *)
        usage
      ;;
    esac
  done
}

get_input() {
  if [[ -z "${instance_clid}" ]]; then
    instance_clid=$(whiptail --title "Nuxeo stacks" --inputbox "Enter the full path of a Nuxeo instance.clid file:" 10 60 "$PWD/instance.clid" 3>&1 1>&2 2>&3)
  fi
  if [[ ! -f ${instance_clid} ]]; then
    >&2 echo "ABORT: Invalid instance.clid file: $instance_clid"
    exit 2
  fi
  if [[ -z "${data_path}" ]]; then
    data_path=$(whiptail --title "Nuxeo stacks" --inputbox "Enter the path to the Nuxeo environment to create:" 10 60 "/tmp/my-nuxeo-env" 3>&1 1>&2 2>&3)
  fi
  if [[ -x "$(command -v realpath)" ]]; then
    data_path="${data_path//\~/$HOME}"
    data_path=`realpath -m ${data_path}`
  fi
  if [[ -z "${nuxeo_dist}" ]]; then
    nuxeo_dist=$(whiptail --title "Nuxeo stacks" --radiolist "Choose a Nuxeo distribution:" 10 60 5 \
 nuxeolatest "Nuxeo latest                  " on \
 nuxeo1010 "Nuxeo 10.10" off \
 nuxeo910 "Nuxeo 9.10" off \
 nuxeo810 "Nuxeo 8.10" off \
 nuxeo710 "Nuxeo 7.10" off \
 none "None" off \
 3>&1 1>&2 2>&3)
  fi
  if [[ -z "${nuxeo_cluster}" ]]; then
    nuxeo_cluster=$(whiptail --title "Nuxeo stacks" --radiolist "Choose a Nuxeo cluster mode:" 10 60 3 \
 no "No cluster                    " on \
 2 "Cluster 2 nodes" off \
 3 "Cluster 3 nodes" off \
 3>&1 1>&2 2>&3)
  fi
  if [[ -z "${backend}" ]]; then
    backend=$(whiptail --title "Nuxeo stacks" --radiolist "Choose a Nuxeo repository backend:" 10 60 3 \
 mongo "MongoDB                          " on \
 postgres "PostgreSQL" off \
 none "Default H2" off \
 3>&1 1>&2 2>&3)
  fi
  if [[ -z "${stacks}" ]]; then
    stacks=$(whiptail --title "Nuxeo stacks" --checklist "Compose your stack:" 18 60 12 \
 elastic "Elasticsearch" on \
 redis "Redis" on \
 kafka "Kafka and Zookeeper" off \
 kafkassl "Kafka in SSL and Zookeeper" off \
 swm "Use Nuxeo Stream WorkManager         " off \
 monitor "Nuxeo Grafana dashboard" off \
 stream "Monitor Nuxeo Stream" off \
 kibana "Elastic GUI" off \
 kafkahq "Kafka GUI" off \
 netdata "Netdata monitoring" off \
 prometheus "Prometheus monitoring" off \
 jaeger "Distributed tracer" off \
 zipkin "Distributed tracer" off \
 3>&1 1>&2 2>&3)
  fi
  COMMAND="${0} -i \"${instance_clid}\" -d \"${data_path}\" -c ${nuxeo_cluster} -n ${nuxeo_dist} -b ${backend} -s '"${stacks}"'"
}

parse_input() {
  if [[ ${nuxeo_dist} == *"nuxeolatest"* ]]; then
    nuxeo=True
    nuxeo_version=latest
  elif [[ ${nuxeo_dist} == *"nuxeo1010"* ]]; then
    nuxeo=True
    nuxeo_version=10.10
  elif [[ ${nuxeo_dist} == *"nuxeo910"* ]]; then
    nuxeo=True
    nuxeo_version=9.10
  elif [[ ${nuxeo_dist} == *"nuxeo810"* ]]; then
    nuxeo=True
    nuxeo_version=8.10
  elif [[ ${nuxeo_dist} == *"nuxeo710"* ]]; then
    nuxeo=True
    nuxeo_version=7.10
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
    kafkassl=False
    kafka=True
    zookeeper=True
    if [[ ${stacks} == *"kafkassl"* ]]; then
      kafkassl=True
    else
      kafkassl=False
    fi
    if [[ ${stacks} == *"kafkahq"* ]]; then
      kafkahq=True
    else
      kafkahq=False
    fi
  else
    kafkassl=False
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
  if [[ ${stacks} == *"prometheus"* ]]; then
    prometheus=True
  else
    prometheus=False
  fi
  if [[ ${stacks} == *"jaeger"* ]]; then
    jaeger=True
  else
    jaeger=False
  fi
  if [[ ${stacks} == *"zipkin"* ]]; then
    zipkin=True
  else
    zipkin=False
  fi
  if [[ ${nuxeo_cluster} == *"2"* ]]; then
    nuxeo_cluster_mode=True
    nuxeo_nb_nodes=2
  elif [[ ${nuxeo_cluster} == *"3"* ]]; then
    nuxeo_cluster_mode=True
    nuxeo_nb_nodes=3
  else
    nuxeo_cluster_mode=False
    nuxeo_nb_nodes=1
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
 -e "env_nuxeo_cluster=$nuxeo_cluster_mode env_nuxeo_nb_nodes=$nuxeo_nb_nodes" \
 -e "env_mongo=$mongo env_postgres=$postgres env_redis=$redis" \
 -e "env_elastic=$elastic env_kibana=$kibana" \
 -e "env_graphite=$graphite -e env_grafana=$grafana" \
 -e "env_kafka=$kafka env_kafkassl=$kafkassl env_zookeeper=$zookeeper env_kafkahq=$kafkahq" \
 -e "env_stream=$stream env_netdata=$netdata env_swm=$swm" \
 -e "env_prometheus=$prometheus  env_jaeger=$jaeger env_zipkin=$zipkin" \
 ${PLAYBOOK_OPTS}
  set +x
}

bye() {
  echo
  echo "---------------------------------------------------------------"
  echo "# This Nuxeo Stack can be rebuilt with the following command:"
  echo ${COMMAND}
  echo "# Next steps:"
  echo "cd ${data_path}"
  echo "docker-compose up"
  echo "http://nuxeo.docker.localhost/nuxeo -> Nuxeo Administrator/Administrator"
  if [[ ${stacks} == *"monitor"* ]]; then
    echo "http://grafana.docker.localhost/ -> Grafana admin/admin"
    echo "http://graphite.docker.localhost/ -> Graphite root/root"
  fi
  if [[ ${stacks} == *"elastic"* ]]; then
    echo "http://elastic.docker.localhost/ -> Elasticsearch"
  fi
  if [[ ${stacks} == *"kibana"* ]]; then
    echo "http://kibana.docker.localhost/ -> Kibana"
  fi
  if [[ ${stacks} == *"kafkahq"* ]]; then
    echo "http://kafkahq.docker.localhost/ -> KafkaHQ"
  fi
  if [[ ${stacks} == *"prometheus"* ]]; then
    echo "http://prometheus.docker.localhost/ -> Prometheus"
  fi
  if [[ ${stacks} == *"jaeger"* ]]; then
    echo "http://jaeger.docker.localhost/ -> Jaeger"
  fi
  if [[ ${stacks} == *"zipkin"* ]]; then
    echo "http://zipkin.docker.localhost/ -> Zipkin"
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
