#!/usr/bin/env bash

source /vagrant/kubernetes/system/get-heapster.sh

set -ex

cd $HEAPSTER_EXTRACTED/influxdb

docker build -t master:5000/influxdb .
docker push master:5000/influxdb