#!/usr/bin/env bash

if [ -z "$POSTGRES_HOST" ]; then
    POSTGRES_HOST=$(kubectl --kubeconfig=/vagrant/kubernetes/kubeconfig get svc | grep stolon-proxy-service | awk '{print $2}')
fi

sudo bash /vagrant/webapp/build.sh > /dev/null
sudo docker run -it --rm --net=host -e POSTGRES_HOST=$POSTGRES_HOST master:5000/webapp "$@"