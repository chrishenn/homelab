# Stalwart: Misc Notes

- The first reboot after wizard config, make sure recovery_mode is NOT on - the admin dash will NOT come up on second boot
  with recovery mode on
- They don't ship the stalwart-cli inside the stalwart container for local access and config

---

## stalwart recovery mode

to put the instance into recovery mode, you can set these

```bash
STALWART_RECOVERY_MODE: true
STALWART_RECOVERY_ADMIN: ${USER}:${STALWART_RECOVERY_PASS}
```

---

## Odd DNS behavior

Occasionally, my local DNS setup will absolutely freak out (it's always DNS). I have a blocky caching DNS proxy on my
local LAN, and it will cache emtpy records (?) not sure exactly what goes wrong - but it makes for an absolutely
scalp-ripping time when debugging.

To clear blocky and local dns caches, I just have to:

```bash
j b c blocky
sudo resolvectl flush-caches
```

---

## tcp-443 pangolin limitation

This is more of a pangolin limitation that I ran into

If you try to route tcp traffic from port 443, pangolin auto-generates an entrypoint 'tcp-443'. Which of course doesn't
exist, because the entrypoint 'websecure' listens on 443.

Yes, I tried renaming pangolin's traefik entrypoint to 'tcp-443' - no bueno. Pangolin expects it to be called
'websecure' and I don't see any indication in the documentation that it would be configurable

I will attempt to workaround this with reusePort and see how it goes

```yml
websecure:
    address: ':443'
    reusePort: true
tcp-443:
    address: ':443'
    reusePort: true
```

- Immediate problems. I curl pangolin, I get 404 - then I get the page.
- like 50/50 odds of it 404'ing
- Oh my god is traffic being load-balanced between websecure and tcp-443?
- Yes lmao the kernel is distributing traffic between the entrypoints, upstream of traefik's service logic. Ok well that's
  not useful at all

---

## tunneling failures

see stalwart_proxy.yml for a more detailed picture of the problem

```bash
# typical failure when sending from residential port 25. note that it takes FOREVER to time out
stalwart | INFO Connection error (delivery.connect-error) queueId = 313394020497752067,
    from = "admin@chenn.dev",
    to = ["chris@henn.dev"],
    domain = "henn.dev",
    hostname = "mail.protonmail.ch",
    localIp = 0.0.0.0,
    remoteIp = 185.70.42.128,
    remotePort = 25,
    causedBy = SMTP error occurred (smtp.error) {
        details = "I/O Error",
        reason = "Connection timed out (os error 110)"
    },
    elapsed = 133924ms

# you may also see "network unreachable"
stalwart | INFO Connection error (delivery.connect-error) queueId = 313394572417827331,
    from = "admin@chenn.dev",
    to = ["christopherpenn1000@gmail.com"],
    domain = "gmail.com",
    hostname = "gmail-smtp-in.l.google.com",
    localIp = 0.0.0.0,
    remoteIp = 2607:f8b0:4023:2c03::1b,
    remotePort = 25,
    causedBy = SMTP error occurred (smtp.error) {
    	details = "I/O Error",
        reason = "Network is unreachable (os error 101)"
    }

# attempting to send through proton's SMTP relay as admin@chenn.dev - nope. you must send from a specific address
# configured in proton and owned by the sender. I think I get 15 addresses with my protonmail subscription
stalwart | INFO SMTP RCPT TO rejected (delivery.rcpt-to-rejected) queueId = 313515071556812801,
    from = "admin@chenn.dev",
    to = ["christopherpenn1000@gmail.com"],
    hostname = "smtp.protonmail.ch",
    to = "christopherpenn1000@gmail.com",
    code = 553,
    details = "<admin@chenn.dev>: Sender address rejected: not owned by user chris@henn.dev",
    elapsed = 129ms
```

---

Long story short, you can terminate TLS at the reverse proxy and send insecure http back to stalwart:8080; this is the
typical setup for traefik/pangolin services and it works for stalwart.

I think you could also use the proxy-protocol to forward raw TCP traffic from port 443 on the reverse proxy back to
stalwart:443 if needed - but I don't need that.

For a lengthy, difficult-to-follow explanation, see: https://stalw.art/docs/server/reverse-proxy/#how-discovery-urls-are-composed
