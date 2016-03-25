#!/bin/bash

if getent hosts rancher-metadata > /dev/null; then
  identity=$(curl http://rancher-metadata/latest/self/container/name)
  echo "identity = ${identity}" >> /etc/puppetlabs/mcollective/server.cfg
fi
