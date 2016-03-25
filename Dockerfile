FROM debian:jessie

MAINTAINER mickael.canevet@camptocamp.com

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

ENV PATH=/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

# Install puppet-agent
ENV RELEASE jessie
RUN apt-get update \
  && apt-get install -y curl locales-all openssh-client \
  && curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-${RELEASE}.deb \
  && dpkg -i puppetlabs-release-pc1-${RELEASE}.deb \
  && rm -rf /var/lib/apt/lists/*

ENV PUPPET_AGENT_VERSION=1.4.0-1${RELEASE}
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
  && mkdir -p /etc/puppetlabs/mcollective/clients /etc/puppetlabs/mcollective/ssl

ONBUILD COPY plugins/ /opt/puppetlabs/mcollective/plugins/

# github_pki
ENV GOPATH=/go
RUN apt-get update && apt-get install -y golang-go git \
  && go get github.com/camptocamp/github_pki \
  && apt-get autoremove -y golang-go git \
  && rm -rf /var/lib/apt/lists/*

# Configure entrypoint
COPY /docker-entrypoint.sh /
COPY /docker-entrypoint.d/* /docker-entrypoint.d/
ONBUILD COPY /docker-entrypoint.d/* /docker-entrypoint.d/
ENTRYPOINT ["/docker-entrypoint.sh", "/opt/puppetlabs/puppet/bin/mcollectived"]
CMD ["--no-daemonize"]
