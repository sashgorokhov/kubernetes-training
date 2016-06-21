#!/usr/bin/env bash

source /vagrant/kubernetes/system/get-heapster.sh

set -ex

cd $HEAPSTER_EXTRACTED/grafana

docker build -t master:5000/grafana .
docker push master:5000/grafana