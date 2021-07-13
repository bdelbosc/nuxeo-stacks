#!/usr/bin/env bash

# Nuxeo stacks
#
export LC_ALL=C
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
    >&2 echo "ABORT: Expecting a Nuxeo instance clid produced with nuxeoctl register, got: $instance_clid"
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
    nuxeo_dist=$(whiptail --title "Nuxeo stacks" --radiolist "Choose a Nuxeo distribution:" 14 60 6 \
 nuxeolatest "Nuxeo nuxeo/nuxeo:latest            " on \
 nuxeo2021 "Nuxeo 2021" off \
 nuxeo1010 "Nuxeo 10.10" off \
 nuxeo910 "Nuxeo 9.10" off \
 nuxeo810 "Nuxeo 8.10" off \
 nuxeo710 "Nuxeo 7.10" off \
 3>&1 1>&2 2>&3)
  fi
  if [[ -z "${nuxeo_cluster}" ]]; then
    nuxeo_cluster=$(whiptail --title "Nuxeo stacks" --radiolist "Choose a Nuxeo cluster mode:" 10 60 3 \
 no "Standalone instance           " on \
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
    stacks=$(whiptail --title "Nuxeo stacks" --checklist "Compose your stack:" 22 72 14 \
 elastic "Elasticsearch (non embedded)" on \
 redis "Redis" on \
 kafka "Kafka (and Zookeeper)" off \
 kafkaconfluent "Confluent Kafka stack with KSQL" off \
 swm "Use the Nuxeo StreamWorkManager impl.    " off \
 monitor "Monitoring with Graphite/Grafana" off \
 prometheus "Expose metrics to Prometheus" off \
 jaeger "Trace Nuxeo with Jaeger" off \
 zipkin "Trace Nuxeo with Zipkin" off \
 netdata "Netdata monitoring" off \
 kafkahq "A GUI for Kafka" off \
 kibana "Elasticsearch Kibana" off \
 minio "Use a Minio S3 for binary storage" off \
 kafkassl "Kafka in SASL_SSL" off \
 stream "Nuxeo Stream monitoring for 10.10 only" off \
 mailhog "Mailhog" off \
 3>&1 1>&2 2>&3)
  fi
  COMMAND="${0} -i \"${instance_clid}\" -d \"${data_path}\" -c ${nuxeo_cluster} -n ${nuxeo_dist} -b ${backend} -s '"${stacks}"'"
}

parse_input() {
  if [[ ${nuxeo_dist} == *"nuxeolatestjx"* ]]; then
    nuxeo=True
    nuxeo_version=latestjx
  elif [[ ${nuxeo_dist} == *"nuxeolatest"* ]]; then
    nuxeo=True
    nuxeo_version=latest
  elif [[ ${nuxeo_dist} == *"nuxeo2021"* ]]; then
    nuxeo=True
    nuxeo_version=2021
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
    nuxeo_version=latestjx
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
  if [[ ${stacks} == *"kafkaconfluent"* ]]; then
    kafkaconfluent=True
    kafkassl=False
    kafka=False
    zookeeper=False
  else
    kafkaconfluent=False
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
  if [[ ${stacks} == *"minio"* ]]; then
    minio=True
  else
    minio=False
  fi
  if [[ ${stacks} == *"mailhog"* ]]; then
    mailhog=True
  else
    mailhog=False
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
  if [[ `command -v ansible-playbook` ]]; then
    return
  fi
  if [[ ! -r ./venv/ ]]; then
    virtualenv ./venv
    venv_activate
    pip install ansible
  fi
}

venv_activate() {
  if [[ `command -v ansible-playbook` ]]; then
    return
  fi
  [[ -f ./venv/bin/activate ]] && source ./venv/bin/activate
}

generate_compose() {
  target_host="`cat hosts`"
  if [[ X"$target_host" == "Xlocalhost" ]]; then
    # No need to ssh when the target is localhost
    ANSIBLE_OPT="--connection=local"
  fi
  set -x
  ansible-playbook site.yml $ANSIBLE_OPT -i ./hosts -e "env_data_path=$data_path env_instance_clid=$instance_clid" \
 -e "env_nuxeo=$nuxeo env_nuxeo_version=$nuxeo_version" \
 -e "env_nuxeo_cluster=$nuxeo_cluster_mode env_nuxeo_nb_nodes=$nuxeo_nb_nodes" \
 -e "env_mongo=$mongo env_postgres=$postgres env_redis=$redis env_minio=$minio" \
 -e "env_elastic=$elastic env_kibana=$kibana" \
 -e "env_graphite=$graphite -e env_grafana=$grafana" \
 -e "env_kafka=$kafka env_kafkassl=$kafkassl env_zookeeper=$zookeeper env_kafkahq=$kafkahq env_kafkaconfluent=$kafkaconfluent"\
 -e "env_stream=$stream env_netdata=$netdata env_swm=$swm" \
 -e "env_prometheus=$prometheus  env_jaeger=$jaeger env_zipkin=$zipkin" \
 -e "env_mailhog=$mailhog" \
 ${PLAYBOOK_OPTS}
  set +x
}

bye() {
  echo "# This Nuxeo Stack was built on `date`, using the following command:" >> ${data_path}/build.log
  echo ${COMMAND} >> ${data_path}/build.log
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
  if [[ ${stacks} == *"minio"* ]]; then
    echo "http://minio.docker.localhost/ -> Minio S3 like"
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
  if [[ ${stacks} == *"kafkaconfluent"* ]]; then
    echo "http://schema.docker.localhost/ -> Confluent Avro Schema Registry"
    echo "http://ksql.docker.localhost/ -> Confluent KSQL Server"
  fi
  if [[ ${stacks} == *"mailhog"* ]]; then
    echo "http://mailhog.docker.localhost/ -> Mailhog"
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
