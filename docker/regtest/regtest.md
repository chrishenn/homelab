# Registry Test

codeberg/forgejo

```bash
# if "create on push" is enabled, there's no need to create the remote repo first
git init && git add --all && git commit -m "init"
git remote add origin ssh://git@forgejo.chenn.dev:2424/chris/$(basename $PWD).git
git push -u origin main

# create repo with berg cli (note that I can't get create+push to work in the one command)
export BERG_BASE_URL=forgejo.chenn.dev
berg auth login --token $(op read "op://homelab/forgejo/pat")

repo=$(basename $PWD)
berg repo create --default-branch main -p private -n $repo -d $repo
git remote add origin ssh://git@forgejo.chenn.dev:2424/chris/$repo.git
git push --set-upstream origin --all
git push --set-upstream origin --tags

# push to container registry
docker login forgejo.chenn.dev
docker build -t forgejo.chenn.dev/chris/regtest:latest . --load --push
```

gitlab

```bash
# you MUST have a project first! the repo is inside the project
gnewrepo

# login. If your user is provided by OIDC/external IDP, use your gitlab PAT as password
export reg='registry.gitlab.chenn.dev'
docker login $reg

# this will also work, but you must push to the registry url
docker login -u chris gitlab.chenn.dev

# project 'regtest' -> deploy -> container registry -> repository 'regtest' -> tag 'latest'
docker build -t $reg/chris/regtest:latest . --load --push

# project 'regtest' -> deploy -> container registry -> repository 'repo_1' -> tag 'latest'
docker build -t $reg/chris/regtest/repo_1:latest . --load --push
```

gitlab (delete repo)

```bash
# you must first delete all registry tags under the repo before being allowed to delete it
# https://docs.gitlab.com/user/packages/container_registry/delete_container_registry_images/
# you can use a garbage collection policy, the gitlab api, or the UI. No glab cli?
# Using the UI to delete a container/tag, it takes a LONG TIME for the delete to happen - like several minutes?
# Then finally the repo will delete
glab repo delete regtest -y
```

forgejo cli (too old to use)

```bash
# using fj cli (NOTE: libgit2 version is too old [unsupported extension name extensions.refstorage])
# git config --unset-all extensions.refstorage
# fj -H forgejo.chenn.dev auth add-key chris $(op read "op://homelab/forgejo/pat")
# fj -H forgejo.chenn.dev repo create --private --push --ssh true $(basename $PWD)

# "create on push" is enabled
git remote add origin ssh://git@forgejo.chenn.dev:2424/chris/$(basename $PWD).git
git push -u origin main
```
