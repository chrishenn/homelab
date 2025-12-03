## Registry Test

forgejo

```bash
docker login forgejo.henn.dev

user=chris
registry=forgejo.henn.dev
image=repotest
tag=latest
docker build -t $registry/$user/$image:$tag . --load --push

docker build -t forgejo.henn.dev/chris/repotest:latest . --load --push
```

gitlab

```bash
# you MUST have a project first! the repo is inside the project
git init
git add --all
git commit -m "init"
if ! glab auth status &>/dev/null; then
    glab auth login --hostname gitlab.henn.dev -g ssh -a gitlab.henn.dev -p https --token $(op read "op://homelab/Gitlab/pat")
fi
glab repo create --defaultBranch "main" --private --skipGitInit
git push --set-upstream origin --all
git push --set-upstream origin --tags

# login
docker login registry.gitlab.henn.dev

# project 'testproject' -> deploy -> container registry -> repository 'testproject' -> tag 'latest'
docker build -t registry.gitlab.henn.dev/chris/testproject:latest . --load --push

# project 'testproject' -> deploy -> container registry -> repository 'repo_1' -> tag 'latest'
docker build -t registry.gitlab.henn.dev/chris/testproject/repo_1:latest . --load --push
```
