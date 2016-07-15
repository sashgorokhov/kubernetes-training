#!/usr/bin/env bash

TOKEN=$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)

kubectl config --kubeconfig /vagrant/kubernetes/kubeconfig set-cluster local --server https://master.example.com --certificate-authority /etc/kubernetes/shared/ssl/ca.pem
kubectl config --kubeconfig /vagrant/kubernetes/kubeconfig set-credentials kubelet --client-certificate /etc/kubernetes/ssl/node.pem --client-key /etc/kubernetes/ssl/node-key.pem
kubectl config --kubeconfig /vagrant/kubernetes/kubeconfig set-context kubelet-context --cluster local --user kubelet
kubectl config --kubeconfig /vagrant/kubernetes/kubeconfig use-context kubelet-context