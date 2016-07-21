#!/bin/bash

MASTER_ID=$(stolonctl --cluster-name="kube-stolon" status | grep Master: | awk '{print $2}')
MASTER_ADDRESS=$(stolonctl --cluster-name="kube-stolon" status | grep -m 1 "^$MASTER_ID" | awk '{print $2}')
MASTER_IP=$(echo ${MASTER_ADDRESS//:/ } | awk '{print $1}')

kubectl --kubeconfig=/vagrant/kubernetes/kubeconfig get po -o wide | grep $MASTER_IP | awk '{print $1}'
