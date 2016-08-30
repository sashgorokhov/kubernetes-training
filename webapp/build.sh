#!/usr/bin/env bash
set -e

VERSION=`cat /vagrant/webapp/VERSION`
TAG="master:5000/webapp:$VERSION"

docker build --rm=true --force-rm -t $TAG /vagrant/webapp
docker push $TAG