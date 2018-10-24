FROM ubuntu:bionic

ENV RELEASE bionic

ENV LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PATH=/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH \
    PUPPET_AGENT_VERSION=5.5.7-1${RELEASE}

# Install puppet-agent
RUN apt-get update \
  && apt-get install -y curl locales-all openssh-client \
  && curl -O http://apt.puppet.com/puppet5-release-${RELEASE}.deb \
  && dpkg -i puppet5-release-${RELEASE}.deb \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  && apt-get install -y puppet-agent=${PUPPET_AGENT_VERSION} \
  && rm -rf /var/lib/apt/lists/*

# Configure mcollectived
RUN sed -i \
   -e 's/^securityprovider = .*$/securityprovider = ssl/' \
   -e 's/stomp1/activemq/' -e 's/6163/61614/' \
   /etc/puppetlabs/mcollective/server.cfg \
  && echo plugin.activemq.pool.1.ssl = true >> /etc/puppetlabs/mcollective/server.cfg \
  && echo plugin.activemq.pool.1.ssl.fallback = true >> /etc/puppetlabs/mcollective/server.cfg \
  && echo plugin.activemq.base64 = yes >> /etc/puppetlabs/mcollective/server.cfg \
  && echo plugin.ssl_client_cert_dir = /etc/puppetlabs/mcollective/clients >> /etc/puppetlabs/mcollective/server.cfg \
  && echo plugin.ssl_server_private = /etc/puppetlabs/mcollective/ssl/server-private.pem >> /etc/puppetlabs/mcollective/server.cfg \
  && echo plugin.ssl_server_public = /etc/puppetlabs/mcollective/ssl/server-public.pem >> /etc/puppetlabs/mcollective/server.cfg \
  && echo logger_type = console >> /etc/puppetlabs/mcollective/server.cfg \
  && echo plugin.activemq.heartbeat_interval = 30 >> /etc/puppetlabs/mcollective/server.cfg \
  && echo plugin.activemq.max_hbread_fails = 2 >> /etc/puppetlabs/mcollective/server.cfg \
  && echo plugin.activemq.max_hbrlck_fails = 2 >> /etc/puppetlabs/mcollective/server.cfg \
  && mkdir -p /etc/puppetlabs/mcollective/clients /etc/puppetlabs/mcollective/ssl

ONBUILD COPY plugins/ /opt/puppetlabs/mcollective/plugins/

# github_pki
RUN apt-get update \
  && apt-get -y install git curl golang \
  && apt-get install -y ca-certificates \
  && go get github.com/camptocamp/github_pki \
  && apt-get purge -y --auto-remove git curl \
  && apt-get clean

# Configure entrypoint
COPY /docker-entrypoint.sh /
COPY /docker-entrypoint.d/* /docker-entrypoint.d/
ONBUILD COPY /docker-entrypoint.d/* /docker-entrypoint.d/
ENTRYPOINT ["/docker-entrypoint.sh", "/opt/puppetlabs/puppet/bin/mcollectived"]
CMD ["--no-daemonize"]
