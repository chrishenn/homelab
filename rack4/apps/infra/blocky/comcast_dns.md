# comcast DNS outage logs

- all DNS requests are timing out
- reboot blocky
    - initial DNS resolution tests to upstream resolvers all failed
    - including 1.1.1.1 and 8.8.8.8
- all public resolvers' IP addresses are pingable
- I could not directly dig from either to resolve google.com

```bash
dig @1.1.1.1 google.com
> timeout

dig @8.8.8.8 google.com
> timeout
```

logs:

rebooted the blocky DNS container around 1:21, but it had been down for a while already (maybe 10 or 20 mins?)

- [2025-10-08 01:21:52] down, but it had been down for a while here already
- [2025-10-08 01:32:50] back up
- [2025-10-08 01:40:20] down
- [2025-10-08 01:59:46] back up
    - (tcp+udp:1.1.1.1) response_type=RESOLVED
    - (tcp+udp:1.0.0.1) response_type=RESOLVED
    - (tcp+udp:8.8.4.4) response_type=RESOLVED
    - (tcp+udp:8.8.8.8) response_type=RESOLVED
