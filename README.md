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

- Graphite
- Grafana
- KafkaHQ
- netdata

# Installation

## Building nuxeo/latest docker image

```
git clone git@github.com:nuxeo/docker-nuxeo.git
cd docker-nuxeo.git/master
docker build -t nuxeo:latest .
```

# Usage

Run `nuxeoenv.sh` and choose:
- your `instance.clid`
- the target environment directory
- the configuration of your stack

This will generate a docker compose file in the target environment directory, 
from there:

```bash
# start
docker-compose up -d
```

You should have:
- Nuxeo running on http://localhost:8080/nuxeo

  ```bash
  # Perform a thread dump
  docker exec nuxeo jcmd Boot Thread.print
  # Run stream.sh with Kafka
  docker exec nuxeo /opt/nuxeo/server/bin/stream.sh lag -k
  ```


- Elasticsearch on http://localhost:9200

  ```bash
  # accessible via curl
  curl -XGET localhost:9200/_cat/indices?v
  ```
  
- MongoDB on localhost:27017 (if selected in your stack)
  
  ```bash
  docker exec mongo mongo localhost/nuxeo --eval "db.default.count();"
  > 26
  ```
  
- PostgreSQL

- Kafka on localhost:9092
  
  ```bash
  # list consumers
  docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh  --bootstrap-server localhost:9092 --list
  # list positions for group nuxeo-default
  docker exec kafka /opt/kafka/bin/kafka-consumer-groups.sh  --bootstrap-server localhost:9092  --describe --group nuxeo-default
  ```
  
- Zookeeper on localhost:2181

- Grafana running on http://localhost:3000 (admin/admin) with a provisioned Nuxeo dashboard

- KafkaHQ running on http://localhost:3080 to introspect Kafka topics

- Graphite running on http://localhost:8000 to look into nuxeo metrics 

- netdata running on http://localhost:1999 to monitor OS and containers


```bash
# stop
docker-compose down --volumes
```

In the `./bin` directory of you env you have many useful shortcut:
- `nuxeoctl.sh`
- `stream.sh`
- `esync.sh` To check the discrepency between repository and elastic


And scripts:
- `import.sh` Run a small import
- `reindex.sh` Re-index elastic using the WorkManger
- `bulk-*` Run bulk command to reindex, export view bulk command or status
- `tail-audit.sh` tail -f on the audit stream
- and more

# TODO

- test script
  - import images (requires install dam) -> -d 10000 -t 10 /path/to/docs/
- elastic head
- flamegraph
- multi env
  - add port offset to run multiple at the same time
  - use traffaek no port exposition by default
- nuxeo cluster mode
- support 9.10

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
