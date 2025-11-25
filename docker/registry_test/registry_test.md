## Registry Test

https://forgejo.org/docs/latest/user/packages/container/

username-based login

```bash
docker login forgejo.henn.dev
```

Images must follow this naming convention:
{registry}/{owner}/{image}

```bash
# build an image with tag
docker build -t {registry}/{owner}/{image}:{tag} .
# name an existing image with tag
docker tag {some-existing-image}:{tag} {registry}/{owner}/{image}:{tag}

docker push forgejo.henn.dev/chris/{image}:{tag}
docker pull forgejo.henn.dev/chris/{image}:{tag}
```

```bash
docker compose build
docker compose push

# or,
user=chris
registry=forgejo.henn.dev
image=repotest
tag=latest
docker build -t $registry/$user/$image:$tag
```

Gitlab. An image is pushed to a container registry that is a sub-repo of an existing project repo.

```bash
# the "image repository with no name" under the "container registry" for the project "testproject"
registry.gitlab.henn.dev/chris/testproject:latest

# the "image repository with name repo1" under the "container registry" for the project "testproject"
registry.gitlab.henn.dev/chris/testproject/repo1:latest

# multiple images can be pushed to an "image repository" with a given name by using different tags
```

```bash
podman login registry.gitlab.henn.dev
podman build -t registry.gitlab.henn.dev/chris/repotest:latest .
podman push registry.gitlab.henn.dev/chris/repotest:latest
```

```bash
docker login registry.gitlab.henn.dev
docker build -t registry.gitlab.henn.dev/chris/testproject:latest . --load --push
docker build -t registry.gitlab.henn.dev/chris/testproject:docker . --load --push
```
