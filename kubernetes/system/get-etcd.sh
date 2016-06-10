#!/usr/bin/env bash

RELEASE_PATH='/vagrant/kubernetes/release'
ETCD_TAR="$RELEASE_PATH/etcd-v2.3.6-linux-amd64.tar.gz"
ETCD_URL="https://github.com/coreos/etcd/releases/download/v2.3.6/etcd-v2.3.6-linux-amd64.tar.gz"
ETCD_EXTRACTED="$RELEASE_PATH/etcd-v2.3.6-linux-amd64"


if [ ! -f $ETCD_TAR ] && [ ! -d $ETCD_EXTRACTED ]; then
    echo Downloading $ETCD_URL
    curl -L  $ETCD_URL -o $ETCD_TAR
fi
if [ ! -d $ETCD_EXTRACTED ]; then
    echo Extracting $ETCD_TAR
    mkdir -p $ETCD_EXTRACTED
    tar -C $ETCD_EXTRACTED --strip-components 1 -xzf $ETCD_TAR 2>/dev/null || true
fi
if [ ! -f  /usr/bin/etcd ]; then
    cp $ETCD_EXTRACTED/etcd /usr/bin/
    chmod +x /usr/bin/etcd
fi
if [ ! -f  /usr/bin/etcdctl ]; then
    cp $ETCD_EXTRACTED/etcdctl /usr/bin/
    chmod +x /usr/bin/etcdctl
fi