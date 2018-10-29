#!/bin/sh

exec /usr/sbin/pdns_server --guardian=no --daemon=no --disable-syslog --write-pid=no $@
