# livekit

Behind pangolin tunnel, livekit uses stun to try to find its public ip - and finds the public ip of the network
that the newt host is running on, NOT the public ip of the pangolin tunnel.

```yaml
stun_servers:
    - stun.l.google.com:19302
    - stun1.l.google.com:19302
```

It does fall back to using the node_ip when validation of that public ip fails - which is what we want - but it does not
always fall back correctly, and there's no chancing it. So just spec the node_ip as a commandline flag.

---

For whatever reason, routing a unique url directly from pangolin to a livekit container with a pangolin resource does not work.
I have to route the livekit public url to the same caddy instance that is reverse-proxying the rest of the application,
and then backhaul from caddy to the livekit container.

On the other hand, using a pangolin target to route livekit traffic on a url subpath works just fine.

## serve on a separate url

```yaml
# caddyfile
http://chatto.chenn.dev {
    ...
}
http://livekit.chatto.chenn.dev {
  reverse_proxy chatto_livekit:7880
}

# whatever application is advertising or connecting to the url
CHATTO_LIVEKIT_URL: wss://livekit.chatto.chenn.dev

# additional pangolin resource
pangolin.public-resources.chatto-livekit.name: chatto-livekit
pangolin.public-resources.chatto-livekit.full-domain: livekit.chatto.chenn.dev
pangolin.public-resources.chatto-livekit.mode: http
pangolin.public-resources.chatto-livekit.targets[0].method: http
pangolin.public-resources.chatto-livekit.targets[0].port: 80
```

## serve on a prefix

```yaml
# caddyfile
:80 {
    encode gzip zstd

    route /livekit* {
        uri strip_prefix /livekit
        reverse_proxy http://chatto_livekit:7880 {
        # I don't think that the chatto application reads the Location header, but stoat probably does
        header_down Location "^/" "/livekit/"
    }
}

# application
CHATTO_LIVEKIT_URL: wss://chatto.chenn.dev/livekit
```

## serve on a prefix, with pangolin

```yaml
# caddyfile - no need to proxy livekit here
:80 {
    encode gzip zstd
    ...
}

# application. same subpath as before
CHATTO_LIVEKIT_URL: wss://chatto.chenn.dev/livekit

# pangolin
services:
  chatto:
    labels:
      pangolin.public-resources.chatto.targets[0].method: http
      pangolin.public-resources.chatto.targets[0].path-match: prefix
      pangolin.public-resources.chatto.targets[0].path: /
      pangolin.public-resources.chatto.targets[0].port: 80
  chatto_livekit:
    labels:
      pangolin.public-resources.chatto.targets[1].method: http
      pangolin.public-resources.chatto.targets[1].path-match: prefix
      pangolin.public-resources.chatto.targets[1].path: /livekit
      pangolin.public-resources.chatto.targets[1].rewrite-match: stripPrefix
      pangolin.public-resources.chatto.targets[1].port: 7880
```

---
