function win_install {
    # match manually with versions from vers.sh
    $kube_ver = "1.33.3"
    $containerd_ver = "2.1.4"
    $crictl_ver = "1.33.0"

    # kb must be installed for VXLAN
    Install-Module -Name PSWindowsUpdate -Force
    Get-windowsupdate -KBArticleID KB4489899 -AcceptAll

    # prereqs for bgp
    Install-WindowsFeature RemoteAccess
    Install-WindowsFeature RSAT-RemoteAccess-PowerShell
    Install-WindowsFeature Routing
    Restart-Computer -Force

    Install-RemoteAccess -VpnType RoutingOnly
    set-service remoteaccess -startuptype Automatic
    Start-Service RemoteAccess

    # install scripts
    $repo = "https://raw.githubusercontent.com/kubernetes-sigs/sig-windows-tools/master/hostprocess"

    # install containerd, containers, hyper-v, hypver-v-powershell
    # (this containerd install does NOT interfere with a docker engine install)
    iwr "$repo/Install-Containerd.ps1" -OutFile C:\Install-Containerd.ps1
    & C:\Install-Containerd.ps1 -ContainerDVersion $containerd_ver -crictlVersion $crictl_ver

    # install kubeadm and kubelet binaries and install the kubelet service
    iwr "$repo/PrepareNode.ps1" -OutFile c:\PrepareNode.ps1
    & c:\PrepareNode.ps1 -KubernetesVersion "v$kube_ver"

    # https://github.com/projectcalico/calico/issues/10596
    mkdir -p \var\run\calico\endpoint-status
}
