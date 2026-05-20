#!/bin/bash

# shellcheck disable=SC2329,SC2091,SC2207,SC2005

# god in heaven this language needs to die
# gnu parallel is cool but there's no straightforward way to return values (except text)

set -e
sdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")

function check_or {
	declare bry=$1
	shift
	if type -P "$bry" >&/dev/null; then
		echo "gclone info: found '$bry'"
		return 0
	else
		echo "gclone error: missing required binary '$bry'"
		return 1
	fi
}

function pushd_q {
	command pushd "$@" &>/dev/null
}

function popd_q {
	command popd &>/dev/null
}

function repo_reset {
	# find name of default branch using github api
	dbr=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
	[[ -z "$dbr" ]] && echo 'error: default branch not found' && return 1 || true

	# find the name of the remote (probably origin)
	drm=$(git remote -v | head -n1 | awk '{print $1}')
	[[ -z "$drm" ]] && echo 'error: remote name not found' && return 1 || true

	# latest commit hash on origin/main
	git fetch --force || echo 'error: git fetch failed' && return 1
	hash=$(git log -n 1 "$drm/$dbr" --pretty=format:"%H")
	[[ -z "$hash" ]] && echo 'error: latest commit hash not found' && return 1 || true

	git reset --hard "$hash" && echo 'repo reset success' && return 0 || echo 'error: git reset failed' && return 1
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

	bpath="$dst/$repo"
	if ! test -d "$bpath"; then
		gh repo clone "$owner/$repo" "$bpath" && return 0 || return 1
	fi

	pushd_q "$bpath"
	git pull --force && popd_q && return 0
	repo_reset && popd_q && return 0 || popd_q && return 1
}

function main {
	declare owner=${1:-'chrishenn'}
	shift
	declare host=${1:-'github.com'}
	shift
	declare dst=${1:-"$HOME/Projects"}
	shift
	declare ssh_keyf=${1:-"$HOME/.ssh/id_ed25519"}
	shift

	cat <<- END

	---- gclone params ----
	owner: 	  $owner
	host: 	  $host
	dst: 	  $dst
	ssh_keyf: $ssh_keyf
	sdir: 	  $sdir

	END

	check_or "git" || exit 1
    check_or "gh" || exit 1
    check_or "jq" || exit 1
    check_or "tr" || exit 1
    check_or "awk" || exit 1
    check_or "ssh-keyscan" || exit 1
    check_or "op" || exit 1
    check_or "parallel" || exit 1

	# git and ssh setup
	mkdir -p $HOME/.ssh
	git config --global --add safe.directory '*'
	git config --global pull.rebase true

	# add github keys to known_hosts to prevent interactive prompt. note: out of date keys will not be updated
	if ! grep -q "github.com" $HOME/.ssh/known_hosts &>/dev/null; then
		ssh-keyscan github.com >> $HOME/.ssh/known_hosts
	fi

	# gh login if not logged in
	if ! gh auth status &>/dev/null; then
		if [ -z "${OP_SERVICE_ACCOUNT_TOKEN}" ]; then
			$(op read op://homelab/svc/bash)
		fi
		if [ -z "${OP_SERVICE_ACCOUNT_TOKEN}" ]; then
			echo 'error: OP_SERVICE_ACCOUNT_TOKEN is empty or unset'
			return 1
		fi
		echo "$(op read 'op://homelab/github/credential')" | gh auth login -h "$host" -p ssh --with-token --skip-ssh-key
		if ! gh auth status &>/dev/null; then
			echo 'error: gh auth login failed'
			return 1
		fi
	fi

	# my github ssh key. note: an out of date ssh keyfile with an old key will not be updated if it exists
	if ! test -f "$ssh_keyf"; then
		op read "op://homelab/dkey/public key" -o "$ssh_keyf.pub" -f
		op read "op://homelab/dkey/private key?ssh-format=openssh" -o "$ssh_keyf" -f
		chmod 600 "$ssh_keyf"
	fi

	# bump this limit -L if you have over 1000 repos
	repos=($(gh repo list -L 1000 --json name | jq '.[].name' | tr -d '"' | sort))

	# todo: would be nice if this tagstring could print output in columns - the obvious fmt strings didnt work

	# parallel. make funcs visible to (bash only) child shells with 'export -f'
	export -f repo_update repo_reset pushd_q popd_q
	parallel --tag --tagstring '{}\t\t' --jl "$sdir/gclone.log" repo_update "$owner" "$host" "$dst" ::: "${repos[@]}"
	fails=$(awk 'NR > 1 {print $7}' "$sdir/gclone.log" | awk '{sum+=$1} END {print sum}')
	succ=$((${#repos[@]} - fails))
	rm "$sdir/gclone.log"

	# serial
	#succ=0
	#for repo in "${repos[@]}"; do
	#	echo "syncing: $repo"
	#	if repo_update $owner $host $dst $repo; then
	#		succ=$((succ + 1))
	#	fi
	#done

	# succ
	echo ''
	echo ''
	echo "counted success: $succ / ${#repos[@]}"
	echo ''
	[[ $succ -eq ${#repos[@]} ]]
}

main "$@" && echo -e "\n SUCCESS with code: $?" || echo -e "\n FAILED with code: $?"
exit
