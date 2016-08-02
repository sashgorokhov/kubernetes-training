#!/usr/bin/env bash

if [ -z "$POSTGRES_HOST" ]; then
    POSTGRES_HOST=$(kubectl --kubeconfig=/vagrant/kubernetes/kubeconfig get svc | grep stolon-proxy-service | awk '{print $2}')
fi

POSTGRES_USER=${POSTGRES_USER:-stolon}
RUN_FLAGS=${RUN_FLAGS:-'--rm'}

sudo bash /vagrant/webapp/build.sh > /dev/null
sudo docker run -it $RUN_FLAGS --net=host -e POSTGRES_HOST=$POSTGRES_HOST -e POSTGRES_USER=$POSTGRES_USER master:5000/webapp "$@"