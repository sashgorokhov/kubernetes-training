#!/usr/bin/env bash
set -ex

sudo puppet apply --modulepath=/vagrant/puppet/modules -e 'class {"releases::heapster":} class {"heapster":}'