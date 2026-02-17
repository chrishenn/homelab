docker compose run --rm -it gluetun_test

gluetun_test:
profiles: [gluetun]
image: alpine
container_name: gluetun_test
restart: no
command: sh -c "wget -O- https://ipinfo.io"

# command: sh -c "wget -O- ip.me"

network_mode: container:gluetun
