# Hybrid {linux, windows} kubernetes cluster

---

# Todo

- [ ] Schedule [github runners](https://github.com/cosmoconsult/github-runner-windows) on linux or windows hosts in the
      same hybrid cluster
- [ ] Install [plane](https://github.com/makeplane/plane)

---

# refs

https://github.com/kubernetes-sigs/sig-windows-tools/blob/master/guides/guide-for-adding-windows-node.md

- obtain a win server license (not necessary?)
- If you are using VXLAN/Overlay networking you must have also have KB4489899 installed

https://yetiops.net/posts/kubernetes-terraform-kvm-linux-windows-part-1/
https://yetiops.net/posts/kubernetes-terraform-kvm-linux-windows-part-2/
https://yetiops.net/posts/kubernetes-terraform-kvm-linux-windows-part-3/

- linux + windows k8s cluster using packer, terraform, ansible, qemu/kvm
- linux and windows are VMs

https://github.com/lippertmarkus/terraform-azurerm-k8s-calico-windows

- azure cloud
- terraform definition for trying out calico for windows
- linux + windows cluster
- 5 years since last update

https://www.suse.com/c/rancher_blog/up-and-running-windows-containers-with-rancher-2-3-and-terraform/

- azure cloud, terraform
- flannel cni in VXLAN mode
- rancher, cert-manager,

https://medium.com/@abhimanyubajaj98/mastering-hybrid-environments-building-aks-cluster-with-linux-and-windows-nodes-using-terraform-38fe59b3f883

- azure (AKS), terraform
- one windows, one linux node
- really easy

https://medium.com/@staneja.st/eks-cluster-with-windows-worker-nodes-using-terraform-de031ca6a019

- EKS k8s: linux + windows cluster defined with terraform

https://computingforgeeks.com/deploy-production-kubernetes-cluster-with-ansible/

- deploy k8s with kubespray/ansible

https://github.com/eldhodevops/docker-windows-ansible

- ansible install docker on windows server
- 6 years old

https://github.com/jimbo8098/windows-docker-role

- ansible install docker on windows server
- 4 years old

https://github.com/cagyirey/packer-windows-server

- uses, DockerMsftProvider, which is deprecated
- ansible install docker on windows vms
- 5 years old

https://www.codecentric.de/en/knowledge-hub/blog/ansible-docker-windows-containers-spring-boot

- ansible install docker on windows vms, using chocolatey
- 8 years old
