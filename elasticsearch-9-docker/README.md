elasticsearch 9.5.5
===================

A docker setup for elasticsearch 9.5.5 (for development purposes).

## Setup

Pull elasticsearch:

```
docker pull docker.elastic.co/elasticsearch/elasticsearch:9.5.5
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
