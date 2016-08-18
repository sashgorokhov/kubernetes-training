#!/usr/bin/env bash
set -e

VERSION=`cat /vagrant/webapp/VERSION`

docker build --rm=true --force-rm -t master:5000/webapp:$VERSION /vagrant/webapp
docker push master:5000/webapp:$VERSION