elasticsearch 7.17.9
===================

A docker setup for elasticsearch 7.17.9 (for development purposes).

## Setup

Pull elasticsearch:

```
docker pull docker.elastic.co/elasticsearch/elasticsearch:7.17.9
```

## Usage

Run this once first:
```
sudo sysctl -w vm.max_map_count=262144
```

Then run docker-compose:
```
docker-compose up -d
```
