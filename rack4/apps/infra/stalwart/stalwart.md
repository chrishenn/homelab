# stalwart

status: this setup is not working - it can recieve mail but not send it

---

https://mail.chenn.dev/admin
the first reboot after wizard config, make sure recovery_mode is not on - the admin dash will come up by default
you can login as the recovery account, but I wonder if it's important to use the generated admin account

proxy subnets:

- i wonder if the subnetting will be a problem

attach

```bash
docker compose exec -it -u 2000 stalwart /bin/bash

docker compose exec -it -u 0:0 stalwart /bin/bash
apt update && apt install -y iputils-ping
```

Of course, you need the stalwart-cli to configure the instance - the config.json won't do. Of course, they don't ship the
stalwart-cli inside the stalwart container for local access and config.

If you try to route tcp traffic from port 443, pangolin auto-generates an entrypoint 'tcp-443'. Which of course doesn't
exist, because the entrypoint 'websecure' listens on 443.

Yes, I tried renaming pangolin's traefik entrypoint to 'tcp-443' - no bueno. Pangolin expects it to be called
'websecure' and I don't see any indication in the documentation that it would be configurable

I will attempt this workaround and see how it goes

- https://doc.traefik.io/traefik/v3.4/routing/entrypoints/

    There is a known bug in the Linux kernel that may cause unintended TCP connection failures when using the ReusePort
    option. For more details, see https://lwn.net/Articles/853637/.

```yml
websecure:
    address: ':443'
    reusePort: true
tcp-443:
    address: ':443'
    reusePort: true
```

Immediate problems. I curl pangolin, I get 404 - then I get the page. like 50/50 odds of it 404'ing
Oh my god is traffic being load-balanced between websecure and tcp-443?
Yes lmao the kernel is distributing traffic between the entrypoints, upstream of traefik's service logic. Ok well that's
not useful at all

So I can't use the cli to do config, which means I have to not break the networking setup while configuring in the UI.
Else I'm hosed. Maybe I can install the cli inside the stalwart container?

```bash
brew install stalwartlabs/tap/stalwart-cli
```

Oh no. The cli works. That must mean that the JMAP tcp transport that we can't implement via pangolin is used for
calendar, mailbox, etc?

```bash
export STALWART_URL=https://mail.chenn.dev
export STALWART_USER
export STALWART_PASSWORD
stalwart-cli query Account
```

    The endpoint itself is served at /jmap and is the primary access point for client operations, including retrieving
    messages, managing mailboxes, and synchronising data.

Huh. Odd

```yml
# traefik docker-provider dynamic router
traefik.tcp.routers.jmap.rule: HostSNI(`*`)
traefik.tcp.routers.jmap.tls.passthrough: true
traefik.tcp.routers.jmap.entrypoints: https
traefik.tcp.routers.jmap.service: jmap
traefik.tcp.services.jmap.loadbalancer.server.port: 443
traefik.tcp.services.jmap.loadbalancer.proxyProtocol.version: 2

# traefik config
https:
    address: :443
    http3: {}
    http:
        tls:
            certResolver: letsencrypt

smtp:
    address: :25
    proxyProtocol:
        trustedIPs:
            - 172.19.0.2
            - 172.19.0.5
```

in the traefik example, proxyProtocol is not enabled on the https entrypoint?

- https://stalw.art/docs/server/reverse-proxy/#how-discovery-urls-are-composed

    HTTP upstream (recommended for simplicity). The proxy terminates TLS for clients and forwards plain HTTP to Stalwart’s HTTP
    listener (default port 8080). This is the conventional reverse-proxy pattern and the one used by every example in the proxy
    guides below. No backend TLS configuration is required.

    HTTPS or TCP-passthrough upstream. The proxy either re-encrypts to Stalwart’s HTTPS listener (default port 443) or passes the
    TLS session through to it untouched (using a TCP-mode router with SNI). This is useful when end-to-end TLS is a deployment
    requirement, when the proxy is on a separate host on an untrusted network, or when Proxy Protocol is being used to preserve
    the client IP on the HTTPS listener.

    Both patterns are documented in the per-proxy pages. Pick the one that fits the operational model of the deployment; the
    OAuth, OIDC, and JMAP discovery responses are identical either way.

hmm. Maybe we're doing option 1, and the examples include the TCP-mode router in case you want option 2. Maybe we're ok!

---

recovery mode

```bash
STALWART_RECOVERY_ADMIN: ${USER}:${STALWART_RECOVERY_PASS}
STALWART_RECOVERY_MODE: true
```

---

- https://www.mail-tester.com/
- https://www.checktls.com/TestReceiver
- https://mxtoolbox.com/SuperTool.aspx

```bash
stalwart | INFO SMTP MAIL FROM command (smtp.mail-from) from = "admin@chenn.dev"
stalwart | INFO SMTP RCPT TO command (smtp.rcpt-to) to = "chris@henn.dev"
stalwart | INFO DKIM verification failed (smtp.dkim-fail) strict = false, result = [], elapsed = 0ms
stalwart | INFO Queued message submission for delivery (queue.authenticated-message-queued) queueId = 313394020497752067, from = "admin@chenn.dev", to = ["chris@henn.dev"], size = 1543, nextRetry = 2026-06-17T17:38:34Z, nextDsn = 2026-06-18T17:38:34Z, expires = 2026-06-20T17:38:34Z
stalwart | INFO Delivery attempt started (delivery.attempt-start) queueId = 313394020497752067, queueName = "remote", from = "admin@chenn.dev", to = ["chris@henn.dev"], size = 1543, total = 1
stalwart | INFO New delivery attempt for domain (delivery.domain-delivery-start) queueId = 313394020497752067, queueName = "remote", from = "admin@chenn.dev", to = ["chris@henn.dev"], size = 1543, total = 1, domain = "henn.dev"
stalwart | INFO Error fetching TLS-RPT record (tls-rpt.record-fetch-error) queueId = 313394020497752067, queueName = "remote", from = "admin@chenn.dev", to = ["chris@henn.dev"], size = 1543, total = 1, domain = "henn.dev", causedBy = Invalid DNS record type (mail-auth.dns-invalid-record-type), elapsed = 22ms
stalwart | INFO Error fetching MTA-STS policy (mta-sts.policy-fetch-error) queueId = 313394020497752067, queueName = "remote", from = "admin@chenn.dev", to = ["chris@henn.dev"], size = 1543, total = 1, domain = "henn.dev", causedBy = Invalid DNS record type (mail-auth.dns-invalid-record-type), strict = false, elapsed = 19ms
stalwart | INFO TLSA record not DNSSEC signed (dane.tlsa-record-not-dnssec-signed) queueId = 313394020497752067, queueName = "remote", from = "admin@chenn.dev", to = ["chris@henn.dev"], size = 1543, total = 1, domain = "henn.dev", hostname = "mail.protonmail.ch", strict = false, elapsed = 124ms
stalwart | INFO Connection error (delivery.connect-error) queueId = 313394020497752067, queueName = "remote", from = "admin@chenn.dev", to = ["chris@henn.dev"], size = 1543, total = 1, domain = "henn.dev", hostname = "mail.protonmail.ch", localIp = 0.0.0.0, remoteIp = 185.70.42.128, remotePort = 25, causedBy = SMTP error occurred (smtp.error) { details = "I/O Error", reason = "Connection timed out (os error 110)" }, elapsed = 133924ms

stalwart | INFO SMTP MAIL FROM command (smtp.mail-from) from = "admin@chenn.dev"
stalwart | INFO SMTP RCPT TO command (smtp.rcpt-to) to = "christopherpenn1000@gmail.com"
stalwart | INFO DKIM verification failed (smtp.dkim-fail) strict = false, result = [], elapsed = 0ms
stalwart | INFO Queued message submission for delivery (queue.authenticated-message-queued) queueId = 313394572417827331, from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1542, nextRetry = 2026-06-17T17:42:57Z, nextDsn = 2026-06-18T17:42:57Z, expires = 2026-06-20T17:42:57Z
stalwart | INFO Delivery attempt started (delivery.attempt-start) queueId = 313394572417827331, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1542, total = 1
stalwart | INFO New delivery attempt for domain (delivery.domain-delivery-start) queueId = 313394572417827331, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1542, total = 1, domain = "gmail.com"
stalwart | INFO Fetched TLS-RPT record (tls-rpt.record-fetch) queueId = 313394572417827331, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1542, total = 1, domain = "gmail.com", details = ["sts-reports@google.com"], elapsed = 37ms
stalwart | INFO Fetched MTA-STS policy (mta-sts.policy-fetch) queueId = 313394572417827331, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1542, total = 1, domain = "gmail.com", strict = true, details = ["smtp.google.com", "gmail-smtp-in.l.google.com", "*.gmail-smtp-in.l.google.com"], elapsed = 104ms
stalwart | INFO Host authorized by MTA-STS policy (mta-sts.authorized) queueId = 313394572417827331, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1542, total = 1, domain = "gmail.com", hostname = "gmail-smtp-in.l.google.com", details = ["smtp.google.com", "gmail-smtp-in.l.google.com", "*.gmail-smtp-in.l.google.com"], strict = true
stalwart | INFO TLSA record not found (dane.tlsa-record-not-found) queueId = 313394572417827331, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1542, total = 1, domain = "gmail.com", hostname = "gmail-smtp-in.l.google.com", strict = false, elapsed = 166ms
stalwart | INFO Connection error (delivery.connect-error) queueId = 313394572417827331, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1542, total = 1, domain = "gmail.com", hostname = "gmail-smtp-in.l.google.com", localIp = 0.0.0.0, remoteIp = 172.253.132.27, remotePort = 25, causedBy = SMTP error occurred (smtp.error) { details = "I/O Error", reason = "Connection timed out (os error 110)" }, elapsed = 132752ms
stalwart | INFO Connection error (delivery.connect-error) queueId = 313394572417827331, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1542, total = 1, domain = "gmail.com", hostname = "gmail-smtp-in.l.google.com", localIp = 0.0.0.0, remoteIp = 2607:f8b0:4023:2c03::1b, remotePort = 25, causedBy = SMTP error occurred (smtp.error) { details = "I/O Error", reason = "Network is unreachable (os error 101)" }, elapsed = 0ms
stalwart | INFO Host authorized by MTA-STS policy (mta-sts.authorized) queueId = 313394572417827331, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1542, total = 1, domain = "gmail.com", hostname = "alt1.gmail-smtp-in.l.google.com", details = ["smtp.google.com", "gmail-smtp-in.l.google.com", "*.gmail-smtp-in.l.google.com"], strict = true
stalwart | INFO TLSA record not found (dane.tlsa-record-not-found) queueId = 313394572417827331, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1542, total = 1, domain = "gmail.com", hostname = "alt1.gmail-smtp-in.l.google.com", strict = false, elapsed = 83ms

stalwart | INFO Connection error (delivery.connect-error) queueId = 313512585479586816, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, domain = "gmail.com", hostname = "gmail-smtp-in.l.google.com", localIp = 0.0.0.0, remoteIp = 172.253.132.26, remotePort = 25, causedBy = SMTP error occurred (smtp.error) { details = "I/O Error", reason = "Connection timed out (os error 110)" }, elapsed = 134913ms
stalwart | INFO Connection error (delivery.connect-error) queueId = 313512585479586816, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, domain = "gmail.com", hostname = "gmail-smtp-in.l.google.com", localIp = 0.0.0.0, remoteIp = 2607:f8b0:4023:2c03::1b, remotePort = 25, causedBy = SMTP error occurred (smtp.error) { details = "I/O Error", reason = "Network is unreachable (os error 101)" }, elapsed = 0ms

stalwart | INFO Connection error (delivery.connect-error) queueId = 313514696567160832, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, domain = "gmail.com", hostname = "smtp.protonmail.ch", localIp = 76.13.30.83, remoteIp = 176.119.200.135, remotePort = 465, causedBy = SMTP error occurred (smtp.error) { details = "I/O Error", reason = "Cannot assign requested address (os error 99)" }, elapsed = 0ms
stalwart | INFO Connection error (delivery.connect-error) queueId = 313514696567160832, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, domain = "gmail.com", hostname = "smtp.protonmail.ch", localIp = 76.13.30.83, remoteIp = 185.205.70.135, remotePort = 465, causedBy = SMTP error occurred (smtp.error) { details = "I/O Error", reason = "Cannot assign requested address (os error 99)" }, elapsed = 0ms
stalwart | INFO Connection error (delivery.connect-error) queueId = 313514696567160832, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, domain = "gmail.com", hostname = "smtp.protonmail.ch", localIp = 76.13.30.83, remoteIp = 185.70.42.135, remotePort = 465, causedBy = SMTP error occurred (smtp.error) { details = "I/O Error", reason = "Cannot assign requested address (os error 99)" }, elapsed = 0ms
stalwart | INFO Message rescheduled for delivery (queue.rescheduled) queueId = 313514696567160832, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, nextRetry = 2026-06-18T09:39:37Z, nextDsn = 2026-06-19T09:37:36Z, expires = 2026-06-21T09:37:36Z
stalwart | INFO Delivery attempt ended (delivery.attempt-end) queueId = 313514696567160832, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, elapsed = 413ms

stalwart | INFO Delivery attempt started (delivery.attempt-start) queueId = 313515071556812801, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1
stalwart | INFO New delivery attempt for domain (delivery.domain-delivery-start) queueId = 313515071556812801, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, domain = "gmail.com"
stalwart | INFO TLSA record not found (dane.tlsa-record-not-found) queueId = 313515071556812801, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, domain = "gmail.com", hostname = "smtp.protonmail.ch", strict = false, elapsed = 524ms
stalwart | INFO Connecting to remote server (delivery.connect) queueId = 313515071556812801, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, domain = "gmail.com", hostname = "smtp.protonmail.ch", localIp = 0.0.0.0, remoteIp = 176.119.200.135, remotePort = 465, elapsed = 130ms
stalwart | INFO SMTP RCPT TO rejected (delivery.rcpt-to-rejected) queueId = 313515071556812801, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, hostname = "smtp.protonmail.ch", to = "christopherpenn1000@gmail.com", code = 553, details = "<admin@chenn.dev>: Sender address rejected: not owned by user chris@henn.dev", elapsed = 129ms
stalwart | INFO DSN permanent failure notification (delivery.dsn-perm-fail) queueId = 313515071556812801, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, to = "christopherpenn1000@gmail.com", hostname = "smtp.protonmail.ch", details = "Unexpected response for RCPT TO:<christopherpenn1000@gmail.com>: Code: 553, Enhanced code: 5.7.1, Message: <admin@chenn.dev>: Sender address rejected: not owned by user chris@henn.dev", total = 0
stalwart | INFO Queued DSN for delivery (queue.dsn-queued) queueId = 313515071556812801, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, queueId = 313515077061837313, from = "<>", to = ["admin@chenn.dev"], size = 3679, nextRetry = 2026-06-18T09:40:38Z, nextDsn = 2082-12-04T19:21:16Z, expires = 2026-06-21T09:40:38Z
stalwart | INFO Delivery completed (delivery.completed) queueId = 313515071556812801, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, elapsed = 3000ms
stalwart | INFO Delivery attempt ended (delivery.attempt-end) queueId = 313515071556812801, queueName = "remote", from = "admin@chenn.dev", to = ["christopherpenn1000@gmail.com"], size = 1546, total = 1, elapsed = 2623ms
stalwart | INFO Delivery attempt started (delivery.attempt-start) queueId = 313515077061837313, queueName = "local", from = "<>", to = ["admin@chenn.dev"], size = 3679, total = 1
stalwart | INFO New delivery attempt for domain (delivery.domain-delivery-start) queueId = 313515077061837313, queueName = "local", from = "<>", to = ["admin@chenn.dev"], size = 3679, total = 1, domain = "chenn.dev"
stalwart | INFO Message ingested (message-ingest.ham) queueId = 313515077061837313, queueName = "local", from = "<>", to = ["admin@chenn.dev"], size = 3679, total = 1, accountId = 1, documentId = 24, mailboxId = [0], blobId = "ba4cb08ed32cc57da5b31bb3f4924af3ab3e8a7e00353fd05cbab6c3d85c7c91", changeId = 80, messageId = "18ba2380bc493d60.2600d3221f7821ec.e6c7c6c5cc91193a@mail.chenn.dev", size = 3679, elapsed = 0ms
stalwart | INFO DSN success notification (delivery.dsn-success) queueId = 313515077061837313, queueName = "local", from = "<>", to = ["admin@chenn.dev"], size = 3679, total = 1, to = "admin@chenn.dev", hostname = "localhost", code = 250, details = "OK"
stalwart | INFO Delivery completed (delivery.completed) queueId = 313515077061837313, queueName = "local", from = "<>", to = ["admin@chenn.dev"], size = 3679, total = 1, elapsed = 0ms
stalwart | INFO Delivery attempt ended (delivery.attempt-end) queueId = 313515077061837313, queueName = "local", from = "<>", to = ["admin@chenn.dev"], size = 3679, total = 1, elapsed = 0ms

```

incoming mail from gmail.com -> stalwart succeeded! also showed up in bulwark.
the send no worky

ip lookup is green. TCP connecting to is the issue

these are all pingable from stalwart container

- ping mail.protonmail.ch
- ping 185.70.42.128
- ping 185.205.70.128
- ping 176.119.200.128
- ping alt4.aspmx.l.google.com
- ping alt1.gmail-smtp-in.l.google.com
- ping 192.178.131.26
- ping gmail-smtp-in.l.google.com

the port 465 is open for inbound, according to an internet port scanner
"network unreachable" yet I can resolve these hostnames and ping these addresses. hmmmmm

---

The issue is that outgoing mail from stalwart is sending from the home ip - not tunneling to the vps and exiting from there.
The home IP is definitely not allowed to send outgoing email.
It would be nice to set up a simple smtp forwarder on the vps, using another stalwart instance - but traefik already
binds to the host's port 465 to forward traffic to the home/pangolin instance. Traefik can't determine a hostname for
routing, because this is a TCP-level router with no headers or host info.

I wonder if we could disable 465 on the home/pangolin instance, if it's used solely for outgoing mail ('submission')?
