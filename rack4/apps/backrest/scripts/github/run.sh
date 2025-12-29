#!/bin/bash

# consts
owner='chrishenn'
host='github.com'
dst='/mnt/h/backup/github'

function repo_update {
    git pull
    if [ $? -eq 0 ]; then
        return
    fi

	# find name of default branch using github api
	dbr=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
	if [ -z "$dbr" ]; then
	    echo 'variable {dbr} is empty or unset'
	    return
    fi

	# find the name of the remote (probably origin)
	drm=$(git remote -v | head -n1 | awk '{print $1}')
	if [ -z "$drm" ]; then
	    echo 'variable {drm} is empty or unset'
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

# 1password
if ! grep -qF "https://downloads.1password.com/linux/alpinelinux/stable/" /etc/apk/repositories; then
	sh -c 'echo https://downloads.1password.com/linux/alpinelinux/stable/ >> /etc/apk/repositories'
fi
if [ ! -f /etc/apk/keys/support@1password.com-61ddfc31.rsa.pub ]; then
	wget https://downloads.1password.com/linux/keys/alpinelinux/support@1password.com-61ddfc31.rsa.pub -P /etc/apk/keys
	apk update && apk add 1password-cli libc6-compat github-cli jq fd
fi

# git and ssh setup
mkdir -p "$HOME/.ssh"
git config --global --add safe.directory '*'
git config --global pull.rebase true
ssh-keyscan github.com > ~/.ssh/known_hosts

# gh login
echo $(op read "op://homelab/github/credential") | gh auth login -h $host -p ssh --with-token --skip-ssh-key

# github ssh key
key="$HOME/.ssh/id_ed25519"
op read "op://homelab/dkey/public key" -o "$key.pub" -f
op read "op://homelab/dkey/private key?ssh-format=openssh" -o $key -f
chmod 600 $key

# remove accidental environment folders
fd '.venv' $dst --fixed-strings -H -I -x rm -rf {}
fd '.pixi' $dst --fixed-strings -H -I -x rm -rf {}

# bump this limit -L if you have over 1000 repos
repos=($(gh repo list -L 1000 --json name | jq '.[].name' | tr -d '"' | sort))
nrepos=${#repos[@]}

i=0
for repo in "${repos[@]}"; do
    echo "syncing: $repo"

	bpath="$dst/$host/$owner/$repo"
	if ! test -d $bpath; then
		gh repo clone $owner/$repo -- $bpath
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
echo "counted success: $i / $nrepos"
echo ''
