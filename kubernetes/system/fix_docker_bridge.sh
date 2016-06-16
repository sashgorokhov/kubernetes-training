#!/usr/bin/env bash
set -ex

sudo stop kubelet || true
sudo stop docker || true
sudo stop flanneld || true

sudo ip link set dev docker0 down || true
sudo brctl delbr docker0 || true

sudo start flanneld
sudo start docker
sudo start kubelet || true