PowerDNS with various backends
==============================

[![](https://images.microbadger.com/badges/image/synyx/pdns.svg)](https://microbadger.com/images/synyx/pdns "Get your own image badge on microbadger.com")

This image provides a reasonably small [PowerDNS][pdns] setup, based on the
[Alpine docker images][alpine-docker]. It supports the following backends out
of the box:

* [Bind zonefiles][pdns-bind]
* [SQLite3][pdns-sqlite]
* [MySQL][pdns-mysql]
* [PostgreSQL][pdns-pgsql]
* [LUA scripting][pdns-lua2]

Via the builtin [webserver][pdns-webserver] it also provides
[Prometheus][prometheus] metrics for easy monitoring of the server.

## Quickstart

The container image needs at least one backend configured to run. An example
based on the [BIND][pdns-bind] backend  with a minimal `example.com` zone can
be easily started from this repository:

```
$ docker run --rm \
    -v $(pwd)/example:/etc/pdns/ \
    -p 1053:53/udp -p 1053:53 -p 8081:8081 \
    synyx/pdns
```

You should then be able to run DNS queries against this zone

```
$ dig -p 1053 www.example.com @localhost

; <<>> DiG 9.10.6 <<>> -p 1053 www.example.com @localhost
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 62192
;; flags: qr aa rd; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;www.example.com.		IN	A

;; ANSWER SECTION:
www.example.com.	86400	IN	CNAME	example.com.
example.com.		86400	IN	A	127.0.0.1

;; Query time: 1 msec
;; SERVER: ::1#1053(::1)
;; WHEN: Thu Jun 16 15:01:59 CEST 2022
;; MSG SIZE  rcvd: 74
```

## Configuration

Configuration for PowerDNS can be done in two ways.

The first & most simple is via environment variables. All possible
[settings][pdns-config] for the PowerDNS server can be set by making the
setting name all uppercase, replacing `-` with `_` and prefixing it with
`PDNS_`. For example, to configure [MySQL backend][pdns-mysql], you can do the
following:

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
`/etc/pdns/pdns.conf`:

```
docker run -d --rm -p 1053:53/udp -p 1053:53 \
  -v ./pdns.conf:/etc/pdns/pdns.conf
```

Both approaches can be combined. The environment variable based config
directory will automatically be added to the configuration with the
`--include-dir` parameter.

## Thanks

* Open-Xchange for [PowerDNS][pdns]

[alpine-docker]: https://hub.docker.com/r/library/alpine/
[kubernetes]: https://kubernetes.io
[pdns]: https://www.powerdns.com
[pdns-config]: https://doc.powerdns.com/md/authoritative/settings/
[pdns-bind]: https://doc.powerdns.com/authoritative/backends/bind.html
[pdns-lua2]: https://doc.powerdns.com/authoritative/backends/lua2.html
[pdns-mysql]: https://doc.powerdns.com/authoritative/backends/generic-mysql.html
[pdns-pgsql]: https://doc.powerdns.com/authoritative/backends/generic-postgresql.html
[pdns-sqlite]: https://doc.powerdns.com/authoritative/backends/generic-sqlite3.html
[pdns-webserver]: https://doc.powerdns.com/authoritative/http-api/index.html
[prometheus]: https://prometheus.io
