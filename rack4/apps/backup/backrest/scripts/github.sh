#!/bin/bash
set -eux

# god in heaven this language needs to die

owner='chrishenn'
host='github.com'
dst='/mnt/h/github'

function repo_reset {
	# find name of default branch using github api
	dbr=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
	[[ -z "$dbr" ]] && echo 'error: default branch not found' && return 1 || true

	# find the name of the remote (probably origin)
	drm=$(git remote -v | head -n1 | awk '{print $1}')
	[[ -z "$drm" ]] && echo 'error: remote name not found' && return 1 || true

	# latest commit hash on origin/main
	git fetch --force || echo 'error: git fetch failed' && return 1
	hash=$(git log -n 1 $drm/$dbr --pretty=format:"%H")
	[[ -z "$hash" ]] && echo 'error: latest commit hash not found' && return 1 || true

	git reset --hard $hash && return 0 || echo 'error: git reset failed' && return 1
}

function repo_update {
	declare owner=$1
	shift
	declare host=$1
	shift
	declare dst=$1
	shift
	declare repo=$1
	shift

	bpath="$dst/$host/$owner/$repo"
	if ! test -d $bpath; then
		gh repo clone $owner/$repo $bpath && return 0 || return 1
	fi

	pushd $bpath
	git pull && popd && return 0
	repo_reset && popd && return 0 || popd && return 1
}

function main {
	# git and ssh setup
	mkdir -p "$HOME/.ssh"
	git config --global --add safe.directory '*'
	git config --global pull.rebase true
	ssh-keyscan github.com >~/.ssh/known_hosts

	# gh login. Ensure OP_SERVICE_ACCOUNT_TOKEN is set or this will fail
	[[ -z "$OP_SERVICE_ACCOUNT_TOKEN" ]] && echo 'error: {OP_SERVICE_ACCOUNT_TOKEN} is empty or unset' && return 1 || true
	echo $(op read "op://homelab/github/credential") | gh auth login -h $host -p ssh --with-token --skip-ssh-key

	# github ssh key - needed for git commands
	# You can't run the op ssh agent without the gui:
	# https://www.1password.community/discussions/developers/how-do-i-use-the-ssh-agent-in-headless-linux/159260
	key="$HOME/.ssh/id_ed25519"
	op read "op://homelab/dkey/public key" -o "$key.pub" -f
	op read "op://homelab/dkey/private key?ssh-format=openssh" -o $key -f
	chmod 600 $key

	# bump this limit -L if you have over 1000 repos
	repos=($(gh repo list -L 1000 --json name | jq '.[].name' | tr -d '"' | sort))
	i=0
	for repo in "${repos[@]}"; do
		echo "syncing: $repo"
		if repo_update $owner $host $dst $repo; then
			i=$((i+1))
		fi
	done

	# chown backed up files
	chown -R 1000:1000 $dst

	# succ
	echo ''
	echo ''
	echo "counted success: $i / ${#repos[@]}"
	echo ''
	[[ $i -eq ${#repos[@]} ]]
}

main && echo -e "\n SUCCESS with code: $?" || echo -e "\n FAILED with code: $?"
exit
