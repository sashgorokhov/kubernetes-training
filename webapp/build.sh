#!/usr/bin/env bash
set -e

VERSION=`cat /vagrant/webapp/VERSION`
TAG="master1:5000/webapp:$VERSION"

docker build --rm=true --force-rm -t $TAG /vagrant/webapp
docker push $TAG

echo Built and pushed: $TAG