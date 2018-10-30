PowerDNS with various backends
==============================

This image provides a reasonably small [PowerDNS][pdns] setup, based
on the [Alpine docker images][alpine-docker]. It supports the following
backends out of the box:

* [Bind zonefiles][pdns-bind]
* [LUA scripting][pdns-lua]
* [MySQL][pdns-mysql]
* [PostgreSQL][pdns-pgsql]
* [SQLite3][pdns-sqlite]
* [Random][pdns-random] (for testing)

It also provides [Prometheus][prometheus] metrics for simple monitoring
of the server. This was done to provide an out-of-the-box container to
use in [Kubernetes][kubernetes].

## Quickstart

The image will run with the [random][pdns-random] backend, providing
random DNS records for `random.example.com` and [Prometheus][prometheus]
metrics on port `9120`. Run with:

```docker run -d --rm -p 1053:53/udp -p 1053:53 -p 9120:9120 synyx/pdns```

PowerDNS should be answering queries shortly after:

```dig -p 1053 random.example.com +short @localhost```

The Prometheus metrics are also available:

```curl localhost:9120/metrics```

## Configuration

Configuration for PowerDNS can be done in two ways.

The first & most simple is via environment variables. All possible
[settings][pdns-config] for the PowerDNS server can be set by making
the setting name all uppercase, replacing `-` with `_` and prefixing
it with `PDNS_`. For example, to configure [MySQL backend][pdns-mysql],
you can do the following:

```
docker run -d --rm -p 1053:53/udp -p 1053:53 -p 9120:9120 \
  -e PDNS_LAUNCH=gmysql \
  -e PDNS_GMYSQL_HOST=mysql.example.com \
  -e PDNS_GMYSQL_DBNAME=pdns \
  -e PDNS_GMYSQL_USER=pdns \
  -e PDNS_GMYSQL_PASSWORD=secret \
  synyx/pdns
```

The second option is, to simply mount a PowerDNS configuration file to
`/etc/pdns/pdns.conf` or `/etc/pdns/pdns.d/myconfig.conf`. The default
configuration will pick up all config files in `/etc/pdns/pdns.d`:

```
docker run -d --rm -p 1053:53/udp -p 1053:53 -p 9120:9120 \
  -v ./myconfig.conf:/etc/pdns/pdns.d/myconfig.conf
```

## Design & Caveats

While the Docker design philosophy is *run a single process*, we wanted
to have out-of-the-box metrics support. Since PowerDNS exposes the
internal metrics mainly via an UNIX socket, the decision was made to use
[runit][runit] to run PowerDNS and the Prometheus exporter side by side.

The caveat is, that now the container won't simply exit or crash when
PowerDNS is misconfigured. Since this container is targeting Kubernetes,
this issue can be remedied by simply applying an in-container health check
by executing `pdns_control rping` periodically.

## Thanks

* Open-Xchange for [PowerDNS][pdns]
* Peter Bourgon for the [runit wrapper][runsvinit]
* Will Rouesnel for the [PowerDNS Prometheus exporter][pdns-exporter]

[alpine-docker]: https://hub.docker.com/r/library/alpine/
[kubernetes]: https://kubernetes.io
[pdns]: https://www.powerdns.com
[pdns-config]: https://doc.powerdns.com/md/authoritative/settings/
[pdns-bind]: https://doc.powerdns.com/md/authoritative/backend-bind/
[pdns-exporter]: https://github.com/wrouesnel/pdns_exporter
[pdns-lua]: https://doc.powerdns.com/md/authoritative/backend-lua/
[pdns-mysql]: https://doc.powerdns.com/md/authoritative/backend-generic-mysql/
[pdns-pgsql]: https://doc.powerdns.com/md/authoritative/backend-generic-pgsql/
[pdns-sqlite]: https://doc.powerdns.com/md/authoritative/backend-generic-sqlite/
[pdns-random]: https://doc.powerdns.com/authoritative/backends/random.html
[prometheus]: https://prometheus.io
[runit]: http://smarden.org/runit/
[runsvinit]: https://github.com/peterbourgon/runsvinit