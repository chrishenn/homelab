#!/bin/bash

# owner, list of repo names
dir='/mnt/h/backup/github/github.com/chrishenn'
owner='chrishenn'

# make sure your op service account token has been injected
# export OP_SERVICE_ACCOUNT_TOKEN=

# prereqs
# brew install gh jq fd 1password-cli

# for debugging
command -v mise >/dev/null 2>&1 && mise deactivate
git config --global --add safe.directory '*'

# login gh
echo $(op read "op://homelab/github/credential") | gh auth login -h github.com -p ssh --with-token --skip-ssh-key

# remove accidental environment folders
fd '.venv' $dir --fixed-strings -H -I -x rm -rf {}
fd '.pixi' $dir --fixed-strings -H -I -x rm -rf {}

function repo_update {
    # todo: try to ff first, then fall back to this hard reset

	# find name of default branch using github api
	dbr=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
	if [ -z "$dbr" ]; then
	    echo 'vaiable {dbr} is empty or unset'
	    return
    fi

	# find the name of the remote (probably origin)
	drm=$(git remote -v | head -n1 | awk '{print $1}')
	if [ -z "$drm" ]; then
	    echo 'vaiable {drm} is empty or unset'
	    return
    fi

	# latest commit hash on origin/main
	git fetch
	hash=$(git log -n 1 $drm/$dbr --pretty=format:"%H")
	if [ -z "$hash" ]; then
	    echo 'variable {hash} is empty or unset'
	    return
    fi

	git reset --hard $hash
}

# bump this limit -L if you have over 1000 repos
repos=($(gh repo list -L 1000 --json name | jq '.[].name' | tr -d '"' | sort))
for repo in "${repos[@]}"; do
	bpath="$dir/$repo"
	if ! test -d $bpath; then
		echo "cloning: $repo"
		gh repo clone $owner/$repo -- $bpath
	else
		echo "syncing: $repo"
		pushd $bpath
		repo_update
		popd
	fi
done
