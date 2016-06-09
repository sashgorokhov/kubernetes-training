#!/usr/bin/env bash

RELEASE_PATH='/vagrant/kubernetes/release'
FLANNEL_TAR="$RELEASE_PATH/flannel-0.5.5-linux-amd64.tar.gz"
FLANNEL_URL="https://github.com/coreos/flannel/releases/download/v0.5.5/flannel-0.5.5-linux-amd64.tar.gz"
FLANNEL_EXTRACTED="$RELEASE_PATH/flannel"


if [ ! -f $FLANNEL_TAR ] && [ ! -d $FLANNEL_EXTRACTED ]; then
    sudo apt-get update > /dev/null
    sudo apt-get install -y wget > /dev/null
    wget --progress=bar:force -nc -O $FLANNEL_TAR $FLANNEL_URL
fi
if [ ! -d $FLANNEL_EXTRACTED ]; then
    mkdir -p $FLANNEL_EXTRACTED
    tar -C $FLANNEL_EXTRACTED --strip-components 1 -xzf $FLANNEL_TAR 2>/dev/null || true
fi
if [ ! -f  /usr/bin/flanneld ]; then
    cp $FLANNEL_EXTRACTED/flanneld /usr/bin/flanneld
    chmod +x /usr/bin/flanneld
fi