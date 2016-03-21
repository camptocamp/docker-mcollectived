#!/bin/sh

if test -n "${MCOLLECTIVE_SERVER_KEY}"; then
  echo "${MCOLLECTIVE_SERVER_KEY}" > /etc/puppetlabs/mcollective/ssl/server-private.pem
  openssl rsa -in /etc/puppetlabs/mcollective/ssl/server-private.pem -pubout > /etc/puppetlabs/mcollective/ssl/server-public.pem
fi
