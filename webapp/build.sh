#!/usr/bin/env bash
set -e

docker build --rm=true --force-rm -t master:5000/webapp /vagrant/webapp
docker push master:5000/webapp