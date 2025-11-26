function alias_install {
	if ! grep -q "alias k='kubectl'" ~/.bash_aliases; then
		printf "\ninstalling aliases\n\n"

		tee -a ~/.bash_aliases <<-'EOF'
			alias k='kubectl'
			alias ka='kubeadm'
			alias ksys='kubectl -n kube-system'
			alias kcal='kubectl -n calico-system'

			alias apply='kubectl apply -f'
			alias delete='kubectl delete -f'

			alias pcat='python3 -m json.tool'

			alias get_svc='kubectl get svc -A -o wide'
			alias get_pod='kubectl get pods -A -o wide'
			alias get_node='kubectl get nodes -A -o wide'

			alias watch_svc='watch -n 1 kubectl get svc -A -o wide'
			alias watch_pod='watch -n 1 kubectl get pods -A -o wide'
			alias watch_node='watch -n 1 kubectl get nodes -o wide'
		EOF
		source ~/.bash_aliases
	else
		printf "\naliases are already installed\n\n"
	fi
}

####
# for reference

function kcont_unset {
	echo "unsetting kube current-context!"
	jaja=$(kubectl config unset current-context)
	if [[ ! "$jaja" =~ "Property \"current-context\" unset" ]]; then
		echo "Error, something weird happend. don't run kube commands"
	fi
	export PS1="\h:\W \u\$ "
}

function kcont_dev {
	echo "attaching to dev"
	kubectl config use-context arn:aws:eks:us-east-2:636307060126:cluster/canopy-cluster
	curr_context=$(k config current-context)
	echo "k config current-context: $curr_context"
	if [[ ! "$curr_context" =~ "636307060126:cluster/canopy-cluster" ]]; then
		echo "Error, something weird happend. don't run kube commands"
		kcont_unset
	else
		export PS1="\e[0;34m[\h dev_canopy \W]\$ \e[m"
	fi
}
