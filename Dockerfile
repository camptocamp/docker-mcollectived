FROM debian:jessie

MAINTAINER mickael.canevet@camptocamp.com

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

ENV PATH=/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

# Install puppet-agent
ENV RELEASE jessie
RUN apt-get update \
  && apt-get install -y curl locales-all \
  && curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-${RELEASE}.deb \
  && dpkg -i puppetlabs-release-pc1-${RELEASE}.deb \
  && rm -rf /var/lib/apt/lists/*

ENV PUPPET_AGENT_VERSION=1.4.0-1${RELEASE}
RUN apt-get update \
  && apt-get install -y puppet-agent=${PUPPET_AGENT_VERSION} \
  && rm -rf /var/lib/apt/lists/*

# Configure mcollectived
RUN sed -i -e 's/6163/61613/' /etc/puppetlabs/mcollective/server.cfg \
  && echo logger_type = console >> /etc/puppetlabs/mcollective/server.cfg

ONBUILD COPY plugins/ /opt/puppetlabs/mcollective/plugins/

# Configure entrypoint
COPY /docker-entrypoint.sh /
ONBUILD COPY /docker-entrypoint.d/* /docker-entrypoint.d/
ENTRYPOINT ["/docker-entrypoint.sh", "/opt/puppetlabs/puppet/bin/mcollectived"]
CMD ["--no-daemonize"]
