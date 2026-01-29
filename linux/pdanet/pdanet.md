# pdanet

alternatives

- https://netshare.app/
- https://tetrd.app/

---

### linux

student script
https://github.com/Posiplusive/pdanet-linux
reverse-engineered linux client
https://github.com/wtyler2505/pdanet-linux

complete instructions on manual global proxy, but also links to using other tools

- https://www.yunielacosta.com/blog/configure-proxy-global-on-linux/
  looks promising:
- https://github.com/mezantrop/ts-warp
  in theory, does what I want:
- https://proxychains.sourceforge.net/
  most recent commit is 2021, but proxifier for linux is exactly what we want
- https://github.com/m0hithreddy/Proxifier-For-Linux
  windscribe (paid)
- https://windscribe.com/?friend=abhyp2zr
  firefox proxy
- settings -> network -> proxy in the gui

```bash
192.168.49.1:8000
```

apt proxy

```bash
# no need to logout/in
> sudo touch /etc/apt/apt.conf.d/pdanet
> sudo nano /etc/apt/apt.conf.d/pdanet

Acquire::http::Proxy "http://192.168.49.1:8000";
```

chromium proxy

```bash
chromium --proxy-server=192.168.49.1:8000
```

---

### windows

git behind proxy
https://stackoverflow.com/questions/783811/getting-git-to-work-with-a-proxy-server-fails-with-request-timed-out
https://bardofschool.blogspot.com/2008/11/use-git-behind-proxy.html

proxying is per-protocol. possibly working on the http and https layer, but git uses some other protocol. probably rewrite git protocol into http?
ping on icmp won't work because it's icmp protocol
but curl will work.

```bash
# DNS does work
ping google.com
>Pinging google.com [142.250.190.78] with 32 bytes of data:

# ping no worky
ping 1.1.1.1
> Request timed out.

# git ssh no work
git pull
> ssh cannot resolve github.com

# curl works
curl -L 1.1.1.1
curl -L google.com

# not needed to set manually when using pdanet desktop
# on
setx http_proxy http://192.168.49.1:8080
setx https_proxy http://192.168.49.1:8080

# off
setx http_proxy http://proxyserver:8080
setx https_proxy http://proxyserver:8080
```
