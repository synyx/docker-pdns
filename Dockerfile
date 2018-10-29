FROM alpine:3.8
MAINTAINER Florian 'hase' Krupicka <hase@synyx.de>

# Allow passing Git commit id as a label
ARG GIT_COMMIT_ID=0000000000000000000000000000000000000000

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="pdns-server" \
      org.label-schema.description="PowerDNS authorative server with some <3-features" \
      org.label-schema.vcs-ref=$GIT_COMMIT_ID \
      org.label-schema.vendor="synyx GmbH & Co. KG"

# Install PowerDNS core packages
RUN echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
 && echo '@edgecommunity http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
 && apk update \
 && apk add boost-program_options@edge \
            pdns@edgecommunity \
            pdns-backend-bind@edgecommunity \
            pdns-backend-lua@edgecommunity \
            pdns-backend-mariadb@edgecommunity \
            pdns-backend-mysql@edgecommunity \
            pdns-backend-pgsql@edgecommunity \
            pdns-backend-random@edgecommunity \
 && rm -rf /var/cache/apk/*

# Add default configuration
COPY ./pdns /etc/pdns

# Expose DNS service ports
EXPOSE 53/udp
EXPOSE 53/tcp

# Entrypoint to whole container
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
