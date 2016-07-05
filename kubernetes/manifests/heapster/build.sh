#!/usr/bin/env bash
set -ex

sudo /opt/puppetlabs/bin/puppet apply --modulepath=/vagrant/puppet/modules -e 'class {"releases::heapster":}->class {"heapster":}'