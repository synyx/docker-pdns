FROM alpine:3.16 AS build-base

# PowerDNS package version
ARG PDNS_PACKAGE_VERSION=4.6.2-r1

# Install PowerDNS core packages and the tini init system.
RUN apk update \
 && apk add pdns=$PDNS_PACKAGE_VERSION \
            pdns-tools=$PDNS_PACKAGE_VERSION \
            pdns-backend-bind=$PDNS_PACKAGE_VERSION \
            pdns-backend-lua2=$PDNS_PACKAGE_VERSION \
            pdns-backend-mariadb=$PDNS_PACKAGE_VERSION \
            pdns-backend-mysql=$PDNS_PACKAGE_VERSION \
            pdns-backend-pgsql=$PDNS_PACKAGE_VERSION \
            pdns-backend-sqlite3=$PDNS_PACKAGE_VERSION \
            tini \
 && rm -rf /var/cache/apk/*

FROM build-base AS build-doc

# We add the doc and manpages, so we can extract schema files for the final
# image.
RUN apk update \
 && apk add pdns-doc=$PDNS_PACKAGE_VERSION \
 && rm -rf /var/cache/apk/*

FROM build-base

# Fetch the SQL schemas from the build-doc stage
COPY --from=build-doc /usr/share/doc/pdns/schema.mysql.sql /usr/share/doc/pdns/
COPY --from=build-doc /usr/share/doc/pdns/schema.pgsql.sql /usr/share/doc/pdns/
COPY --from=build-doc /usr/share/doc/pdns/schema.sqlite3.sql /usr/share/doc/pdns/

# Expose DNS service ports
EXPOSE 53/udp
EXPOSE 53/tcp

# Entrypoint to whole container
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/sbin/tini", "--", "/entrypoint.sh" ]

LABEL org.opencontainers.image.authors="Florian 'hase' Krupicka <krupicka@synyx.de>" \
      org.opencontainers.image.url="https://github.com/synyx/docker-pdns" \
      org.opencontainers.image.vendor="synyx GmbH & Co. KG" \
      org.opencontainers.image.title="PowerDNS authorative server" \
      org.opencontainers.image.description="A PowerDNS authorative server with support of configuration via environment"
