# Nuxeo docker compose full stack

A docker compose to deploy quickly Nuxeo with a full stack of services:
- elasticsearch
- mongodb
- zookeeper
- kafka
- graphite
- grafana
- nuxeo

The intend of this environment is for testing/debugging NOT FOR PRODUCTION.

# Installation

## Building nuxeo/latest image

```
git clone git@github.com:nuxeo/docker-nuxeo.git
cd docker-nuxeo.git/master
docker build -t nuxeo:latest .
```

## Configure your env

Create a `.env` file with:
```
DATA_DIR=<CURRENT_PATH/data>
INSTANCE_CLID=</full/path/to/a/nuxeo/instance.clid>
```

All the service's volumes will be in the `./data` directory.

Check the `nuxeo.conf` file.

# Usage

```
# start
docker-compose up -d


# stop
docker-compose down
```

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
