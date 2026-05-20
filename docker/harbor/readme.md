# harbor

## NOTE: harbor is abandonware.

I can't push a very basic image built on top of alpine, becuase of a bug that is almost a year old:
https://github.com/goharbor/harbor/issues/22078

I literally can't use harbor for my simple-ass use case. Sadge!

---

# ranting

Deploying this project is an ABSOLUTE DISASTER. After that, it seems very nice ...

what's the point of shipping containers if you can only deploy in one very specific (buggy) way?
not to mention the stupid bash script doesn't work on read-only fs (of course bash scripts always break! always!)
it is so thorough, so well-considered, yet so dumb

hardcodes service names into a million individual config files. why
renders secrets directly to disk. why
the "installer" runs a docker container to "prepare" the install - making remote docker host unusable. WHY
services don't follow the harbor- prefix naming scheme. why
the bespoke postgres image is based on pg15. WHY WHY WHY
databases can't chmod their storage dirs. omg why
their installer script seems to have replaced "reg.henn.dev" with "reg.henn.com"
configuration values are smeared between env and config files
these things really like to fail with no human-readable error message. infuriating

WHY WOULD YOU DO THIS

why specifically add permissions to chown files if you're not going to use them?!??
WHY DO I HAVE TO CHANGE PERMISSIONS MANUALLY!?!?

OH MY GOD THE ENVIRONMENT VARIABLES OVERLAP BETWEEN SERVICES? WHY WHY WHY WHY WHAT IS THE POINT OF THIS

# necessary fixes / manual steps

```bash
# containers won't set file perms
sudo chmod -R 777 $DATA/harbor/db
sudo chmod -R 777 $DATA/harbor/redis
sudo chmod -R 777 $DATA/harbor/storage

# formatting issue with this keyfile - documentation is buggy - why do I need to generate this in the first place?
openssl genrsa -out config/private_key.pem 4096
openssl req -new -x509 -key config/private_key.pem -out root.crt -days 3650
openssl pkey -in config/private_key.pem -traditional
```

You can definitely change the service names - just hunt through the config files for mentions of the 'redis' host and
replace as needed.

# troubleshooting

```bash
dc down registry registryctl postgresql core portal jobservice redis
dc up -d registry registryctl postgresql core portal jobservice redis

curl -u user:pass https://reg.henn.dev/v2/_catalog
docker login reg.henn.dev

# create project using the api
curl -u admin:YourPassword -X POST \
    "https://reg.henn.dev/api/v2.0/projects" \
    -H "Content-Type: application/json" \
    -d '{
        "project_name": "testproject",
        "public": false,
        "storage_limit": -1,
        "metadata": {
            "auto_scan": "true",
            "severity": "high"
            }
        }'

# add instance as http (insecure) registry for testing
"insecure-registries" : [ "192.168.1.142:9001" ],
```

I replaced one nginx instance with traefik rules

```yml
proxy:
    profiles: [harbor]
    image: goharbor/nginx-photon:v2.14.4
    container_name: nginx
    restart: unless-stopped
    cap_add: [CHOWN, SETGID, SETUID, NET_BIND_SERVICE]
    volumes:
        - $HOME/harbor/cert:/harbor_cust_cert
        - ./config/proxy.conf:/etc/nginx/nginx.conf
    networks: [harbor, traefik]
    labels:
        traefik.enable: true
        traefik.http.routers.reg.rule: Host(`reg.henn.dev`)
        traefik.http.routers.reg.entrypoints: websecure
        traefik.http.routers.reg.middlewares: hdrs@file
        traefik.http.routers.reg.tls.certresolver: cf
        traefik.http.services.reg.loadbalancer.server.port: 8080
```
