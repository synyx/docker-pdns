FROM alpine:3.8
MAINTAINER Florian 'hase' Krupicka <hase@synyx.de>

# PowerDNS package version
ARG PDNS_PACKAGE_VERSION=4.1.3-r0

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="pdns" \
      org.label-schema.description="PowerDNS authorative server with some <3-features" \
      org.label-schema.vendor="synyx GmbH & Co. KG"

# Install PowerDNS core packages
RUN apk update \
 && apk add pdns=$PDNS_PACKAGE_VERSION \
            pdns-backend-bind=$PDNS_PACKAGE_VERSION \
            pdns-backend-lua=$PDNS_PACKAGE_VERSION \
            pdns-backend-mariadb=$PDNS_PACKAGE_VERSION \
            pdns-backend-mysql=$PDNS_PACKAGE_VERSION \
            pdns-backend-pgsql=$PDNS_PACKAGE_VERSION \
            pdns-backend-random=$PDNS_PACKAGE_VERSION \
            pdns-backend-sqlite3=$PDNS_PACKAGE_VERSION \
            runit \
 && rm -rf /var/cache/apk/*

RUN wget https://github.com/peterbourgon/runsvinit/releases/download/v2.0.0/runsvinit-linux-amd64.tgz \
 && tar xzf runsvinit-linux-amd64.tgz \
 && chown root:root /runsvinit \
 && rm runsvinit-linux-amd64.tgz

RUN wget -O pdns_exporter \
    https://github.com/wrouesnel/pdns_exporter/releases/download/v0.0.3/pdns_exporter.x86_64 \
 && chmod +x pdns_exporter

# Add default configuration
COPY ./pdns /etc/pdns

# Expose DNS service ports
EXPOSE 53/udp
EXPOSE 53/tcp

# Expose PowerDNS prometheus metrics
EXPOSE 9120/tcp

# Add Runit service definitions
COPY ./service /etc/service

# Entrypoint to whole container
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
