# Nuxeo stacks: a docker compose generator

The intend of nuxeo stacks is to create custom environment to test/debug Nuxeo stacks.

This is **NOT FOR PRODUCTION.**

You choose your stack and it creates a standalone environment with normal docker compose and volumes.

Here is the supported stack for Nuxeo 10.10 and 9.10:

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

## Requirements

In addition to docker and [docker-compose](https://docs.docker.com/compose/install/) needed to run the stack.

The generation of the docker compose stack is done using ansible which need:

1. pip
2. virtualenv
3. whiptail


To install this requirement on Mac OS:
```bash
brew install python
pip3 install virtualenv
brew install newt
```

For Ubuntu:
```yaml
sudo apt install python3-pip
pip3 install virtualenv
```

## Nuxeo docker images

When choosing a stack based on "Nuxeo latest", it requires the `nuxeo:latest` image.
This image can be built using the `docker-nuxeo` scripts:
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
from there, you can up/stop your env like any docker compose env.

```bash
# Add a -d to run in background
docker-compose up
# List docker containers
docker ps
# Stops containers and removes containers and named volumes
docker-compose down --volume
```

Note that you can use `stop` to stop an env but you need to use `down --volume` before switching to different stack or you will have error like:
```bash
ERROR: for elastic  Cannot create container for service elasticsearch: Conflict. The container name "/elastic" is already in use by container "3a7a444f4a01e0286ea54edabde0549be8564fd538d72d88b58661f6e73c4c62". You have to remove (or rename) that container to be able to reuse that name.
```

All data are persisted using docker volumes inside your env, you can resume any env using a `docker-compose up`.


# Stack exposition

Once the docker compose is up, you should have (depending on what you have selected in your stack)

- Nuxeo running on http://localhost:8080/nuxeo with `nuxeo-web-ui`, `nuxeo-jsf-ui` and `nuxeo-platform-importer` marketplace packages.

- Elasticsearch on http://localhost:9200

- MongoDB on localhost:27017
  
- PostgreSQL on localhost:5432

- Kafka on localhost:9092
    
- Zookeeper on localhost:2181

- Redis

- Kibana running on http://localhost:5601 (elastic/changeme)

- Grafana running on http://localhost:3000 (admin/admin) with a provisioned Nuxeo dashboard

- KafkaHQ running on http://localhost:3080 to introspect Kafka topics

- Graphite running on http://localhost:8000 to look into nuxeo metrics

- netdata running on http://localhost:1999 to monitor OS and containers
  Note that it is much better to install netdata directly on the host (not dockerised)


## Battery included

In the `./bin` directory of you env you have many useful shortcut:
- `nuxeoctl.sh` direct exposition of the nuxeoctl of your env
- `stream.sh` direct exposition of the stream.sh of your env
- `mongo.sh` Run the mongo client
- `psql.sh` Run the PostgreSQL client
- `redis-cli.sh` Run the redis client


And scripts:
- `esync.sh` Run the [esync](https://github.com/nuxeo/esync) tool to check the discrepancy between repository and elastic
- `import.sh` Run a small import 1k docs
- `reindex.sh` Re-index elastic using the WorkManger
- `tail-audit.sh` tail -f on the audit stream
- `threaddump.sh` Perform a thread dump of Nuxeo
- `pg-info.sh` Perform the PosgreSQL reporting problem procedure
- `elastic-info.sh` Perform the Elasticsearch reporting problem procedure
- `bulk-done.sh` List latest bulk command completed
- `bulk-scheduled.sh` List latest bulk command scheduled
- `bulk-reindex.sh` Run bulk command to re-index the repository
- `bulk-export.sh` Run bulk CSV export of the repository
- `bulk-status.sh` Get the status of the last submitted bulk command
- `kafka-list-consumer-gropus.sh` List all consumer groups at Kafka level.
- `kafka-list-consumer-positions.sh` List the a consumer group position at Kafka level.


# TODO

- Support 8.10 stack
- Media importer using DAM
- Elastic head plugin -> nginx ?
- Flight recorder -> build Nuxeo image with Oracle or check latest OpenJDK
- Java flamegraph
- Support cluster mode, deploy multiple Nuxeo
- Multi env
  - Expose only one chosen port
  - Use traefik to root all web ui /nuxeo/ /grafana /kafkahq ...
  - Prefix name for container and volume


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
