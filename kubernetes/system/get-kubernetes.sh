#!/usr/bin/env bash

RELEASE_PATH='/vagrant/kubernetes/release'
KUBERNETES_TAR="$RELEASE_PATH/kubernetes.tar.gz"
KUBERNETES_URL="https://github.com/kubernetes/kubernetes/releases/download/v1.2.4/kubernetes.tar.gz"
KUBERNETES_EXTRACTED="$RELEASE_PATH/kubernetes"
BINARIES_DIR="$KUBERNETES_EXTRACTED/server/bin"


if [ ! -f $KUBERNETES_TAR ] && [ ! -d $KUBERNETES_EXTRACTED ]; then
    echo Downloading $KUBERNETES_URL
    curl -s -L  $KUBERNETES_URL -o $KUBERNETES_TAR
fi
if [ ! -d $KUBERNETES_EXTRACTED ]; then
    echo Extracting $KUBERNETES_TAR
    mkdir -p $KUBERNETES_EXTRACTED
    tar -C $KUBERNETES_EXTRACTED --strip-components 1 -xzf $KUBERNETES_TAR 2>/dev/null || true
fi
if [ ! -d $BINARIES_DIR ]; then
    tar -C $KUBERNETES_EXTRACTED --strip-components 1 -xzf $KUBERNETES_EXTRACTED/server/kubernetes-server-linux-amd64.tar.gz 2>/dev/null || true
fi
if [ ! -f  /usr/bin/hyperkube ]; then
    cp $BINARIES_DIR/hyperkube /usr/bin/hyperkube
    chmod +x /usr/bin/hyperkube
fi
if [ ! -f  /usr/bin/kubectl ]; then
    cp $BINARIES_DIR/kubectl /usr/bin/kubectl
    chmod +x /usr/bin/kubectl
fi