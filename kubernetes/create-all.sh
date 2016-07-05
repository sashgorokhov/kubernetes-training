#!/usr/bin/env bash
set -ex

kubectl --server=http://master:8080 create -f /vagrant/kubernetes/manifests/kube-dns
kubectl --server=http://master:8080 create -f /vagrant/kubernetes/manifests/dashboard
sudo bash /vagrant/kubernetes/manifests/heapster/build.sh
kubectl --server=http://master:8080 create -f /vagrant/kubernetes/manifests/heapster
sudo bash /vagrant/webapp/build.sh
kubectl --server=http://master:8080 create -f /vagrant/kubernetes/manifests/webapp
sudo docker kill $(sudo docker ps | grep k8s_heapster | awk '{print $1}')