#!/bin/bash

owner='chrishenn'
host='github.com'
dst='/mnt/h/github'

function repo_update {
	git pull
	if [ $? -eq 0 ]; then
		return
	fi

	# find name of default branch using github api
	dbr=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
	[ -z "$dbr" ] && echo 'error: variable {dbr} is empty or unset'
	return

	# find the name of the remote (probably origin)
	drm=$(git remote -v | head -n1 | awk '{print $1}')
	[ -z "$drm" ] && echo 'error: variable {drm} is empty or unset'
	return

	# latest commit hash on origin/main
	git fetch
	hash=$(git log -n 1 $drm/$dbr --pretty=format:"%H")
	[ -z "$hash" ] && echo 'error: variable {hash} is empty or unset'
	return

	git reset --hard $hash
}

function main {
	# git and ssh setup
	mkdir -p "$HOME/.ssh"
	git config --global --add safe.directory '*'
	git config --global pull.rebase true
	ssh-keyscan github.com >~/.ssh/known_hosts

	# gh login. Ensure OP_SERVICE_ACCOUNT_TOKEN is set or this will fail
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

		bpath="$dst/$host/$owner/$repo"
		if ! test -d $bpath; then
			gh repo clone $owner/$repo $bpath
			[[ $? -eq 0 ]] && ((i++))
		else
			pushd $bpath
			repo_update
			[[ $? -eq 0 ]] && ((i++))
			popd
		fi
	done

	# chown backed up files
	chown -R 1000:1000 $dst

	# succ
	echo ''
	echo ''
	echo "counted success: $i / ${#repos[@]}"
	echo ''
}

main
echo -e "\n exited with code: $?"
exit
