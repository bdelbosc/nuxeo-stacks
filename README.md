# Nuxeo stacks a docker compose generator

The intend of nuxeo stacks is to create custom environment to test/debug Nuxeo stacks.
This is NOT FOR PRODUCTION.

You choose your stack and it creates a standalone environment with normal docker compose and volumes.
Available services in addition to Nuxeo:

- MongoDB
- PostgreSQL
- Elasticsearch
- Kafka
- Zookeeper
- Redis

And monitoring tools:

- Grafana (Graphite) Nuxeo dashboard 
- KafkaHQ A Kafka GUI
- Kibana An Elasticsearch GUI
- Netdata OS monitoring

# Installation

## Building nuxeo/latest docker image

```
git clone git@github.com:nuxeo/docker-nuxeo.git
cd docker-nuxeo.git/master
docker build -t nuxeo:latest .
```

# Usage

Run `nuxeoenv.sh` and compose your stack:
- Select a valid Nuxeo `instance.clid`
- Select the target environment directory that will contains all your env (docker-compose and its data)
- Select a Nuxeo distribution
- Select a Backend
- Select additional services (elastic, redis, kafka, grafana ...)

This will generate a docker compose file in the target environment directory, 
from there, you can start stop your env like any docker-compose env.

```bash
# Add a -d to run in background
docker-compose up
# List docker containers
docker ps
# Stops containers and removes containers and named volumes
docker-compose down --volume
```

Note that you can use `stop` and `start` but you need to use `down --volume` before switching to another stack or you will have error like:
```bash
ERROR: for elastic  Cannot create container for service elasticsearch: Conflict. The container name "/elastic" is already in use by container "3a7a444f4a01e0286ea54edabde0549be8564fd538d72d88b58661f6e73c4c62". You have to remove (or rename) that container to be able to reuse that name.
```
All data are persisted into volume inside your env, so you can resume any env using a `docker-compose up`. 


# Stack exposition

Once the docker compose is up, you should have (depending on what you have selected in your stack)

- Nuxeo running on http://localhost:8080/nuxeo with `nuxeo-web-ui`, `nuxeo-jsf-ui` and `nuxeo-platform-importer` marketplace packages.

  ```bash
  # Perform a thread dump
  docker exec nuxeo jcmd Boot Thread.print
  # Run stream.sh with Kafka
  docker exec nuxeo /opt/nuxeo/server/bin/stream.sh lag -k
  ```

- Elasticsearch on http://localhost:9200

  ```bash
  curl -XGET localhost:9200/_cat/indices?v
  ```
  
- MongoDB on localhost:27017
  
  ```bash
  docker exec mongo mongo localhost/nuxeo --eval "db.default.count();"
  > 26
  ```
  
- PostgreSQL on localhost:5432

  ```bash
  $ docker exec  postgres psql postgresql://nuxeo:nuxeo@postgres:5432/nuxeo -c "SELECT COUNT(*) FROM hierarchy;"
  count 
  -------
      92
  ```

- Kafka on localhost:9092
  
  ```bash
  # list consumers
  docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh  --bootstrap-server localhost:9092 --list
  # list positions for group nuxeo-default
  docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh  --bootstrap-server localhost:9092  --describe --group nuxeo-default
  ```
  
- Zookeeper on localhost:2181

- Redis TODO

- Kibana running on http://localhost:5601 (elastic/changeme)

- Grafana running on http://localhost:3000 (admin/admin) with a provisioned Nuxeo dashboard

- KafkaHQ running on http://localhost:3080 to introspect Kafka topics

- Graphite running on http://localhost:8000 to look into nuxeo metrics

- netdata running on http://localhost:1999 to monitor OS and containers
  Note that it is much better to install netdata on the host instead as in container


## Battery included

In the `./bin` directory of you env you have many useful shortcut:
- `nuxeoctl.sh` direct exposition of the nuxeoctl of your env
- `stream.sh` direct exposition of the stream.sh of your env
- `mongo.sh` Run the mongo client
- `psql.sh` Run the PostgreSQL client


And scripts:
- `esync.sh` run the [esync](https://github.com/nuxeo/esync) tool to check the discrepancy between repository and elastic
- `import.sh` Run a small import 1k docs
- `reindex.sh` Re-index elastic using the WorkManger
- `tail-audit.sh` tail -f on the audit stream
- `threaddump.sh` Perform a thread dump of Nuxeo
- `bulk-done.sh` List latest bulk command completed
- `bulk-scheduled.sh` List latest bulk command scheduled
- `bulk-reindex.sh` Run bulk command to re-index the repository
- `bulk-export.sh` Run bulk CSV export of the repository
- `bulk-status.sh` Get the status of the last submitted bulk command

# TODO

- test script
  - import images (requires install dam) -> -d 10000 -t 10 /path/to/docs/
- elastic head
- flamegraph
- support cluster mode
- multi env
  - do not expose any port but the choosen one
  - use traefik to root all web /nuxeo/ /grafana /kafkahq ...



# About Nuxeo

Nuxeo provides a modular, extensible Java-based
[open source software platform for enterprise content management](http://www.nuxeo.com/en/products/ep)
and packaged applications for
[document management](http://www.nuxeo.com/en/products/document-management),
[digital asset management](http://www.nuxeo.com/en/products/dam) and
[case management](http://www.nuxeo.com/en/products/case-management). Designed
by developers for developers, the Nuxeo platform offers a modern
architecture, a powerful plug-in model and extensive packaging
capabilities for building content applications.

More information on: <http://www.nuxeo.com/>
