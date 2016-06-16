#!/usr/bin/env bash

RELEASE_PATH='/vagrant/kubernetes/release'
HEAPSTER_TAR="$RELEASE_PATH/heapster-1.0.2.tar.gz"
HEAPSTER_URL="https://github.com/kubernetes/heapster/archive/v1.0.2.tar.gz"
HEAPSTER_EXTRACTED="$RELEASE_PATH/heapster"


if [ ! -f $HEAPSTER_TAR ] && [ ! -d $HEAPSTER_EXTRACTED ]; then
    echo Downloading $HEAPSTER_URL
    curl -L  $HEAPSTER_URL -o $HEAPSTER_TAR
fi
if [ ! -d $HEAPSTER_EXTRACTED ]; then
    echo Extracting $HEAPSTER_TAR
    mkdir -p $HEAPSTER_EXTRACTED
    tar -C $HEAPSTER_EXTRACTED --strip-components 1 -xzf $HEAPSTER_TAR 2>/dev/null || true
fi