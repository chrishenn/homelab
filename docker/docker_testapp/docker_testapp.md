# Docker App Test Images

build images that have an app installed for testing

each test container will copy and use the same configuration file

---

## Run Test Pods

run all test pods:

```shell
docker compose up -d
docker compose exec rhel bash
docker compose exec debian bash
...
docker compose down
```

run one:

```shell
docker compose up -d al2023
docker compose exec al2023 bash
...
docker compose down al2023
```

alternatively, podman:

```shell
podman build -t al2023:latest -f Containerfile-test-al2023-x86_64 .
podman run -d --hostname al2023 --name al2023 al2023:latest
podman exec -it al2023 bash
podman rm -f al2023
```

---

You can run and connect to a single container/service with `docker compose run`. However, you will have to
manually kill the shell after logging in with this method. Then, you'll have to manually kill the compose service with
`docker compose kill` and then cleanup with the `docker compose down` command as well.

Note that the shell connected to the container will prompt for username and password after systemd boots. The default
user/pass is root/root for each of these helper images.

Given the extra commands, it's typically simpler to just use `docker compose up -d <service-name>` and use `docker exec`
to connect to the running container (described above)

```shell
docker compose run -d --rm debian
docker compose exec debian bash
...
docker compose kill debian
docker compose down debian
```
