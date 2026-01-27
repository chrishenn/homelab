# set up a fresh windows server


# TUI config
# sconfig - install updates
# sconfig - set static ip
# sconfig - rename computer


# add user
net user chris <pass> /add /active:yes
net localgroup administrators chris /add

# disable password expiry
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "PasswordPolicy" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordPolicy" -Name `
    "DisablePasswordExpiration" -Value 1 -Type DWORD -Force

# ssh server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service ssh-agent

# script policy set unrestricted
Set-ExecutionPolicy -scope LocalMachine -ExecutionPolicy Unrestricted -force
Set-ExecutionPolicy -scope CurrentUser -ExecutionPolicy Unrestricted -force

# scoop
iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
scoop install git aria2
scoop config aria2-warning-enabled false
scoop bucket add extras
scoop install pwsh gow bottom

# set openssh default login shell to pwsh
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
    -Name DefaultShell `
    -Value (scoop shim info pwsh).path `
    -PropertyType String `
    -Force

# firewall disable (default firewall rules will block ping and ssh unless manually allowed), uninstall defender
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Uninstall-WindowsFeature Windows-Defender

# enable long paths
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1

# rename computer
Rename-Computer -NewName "rack1"

# reboot before creating a network share
restart-computer

# smb share the c drive
New-SmbShare -Name C -Path "C:\" -FullAccess "Everyone"

# enable smbdirect
# https://enterprise-support.nvidia.com/s/article/howto-configure-smb-direct--roce--over-pfc-on-windows-2012-server
enable-windowsoptionalfeature -online -featurename smbdirect -all -norestart
Set-SmbServerConfiguration -EnableMultiChannel $true
Set-SmbClientConfiguration -EnableMultiChannel $true -force
# set for interface
Enable-NetAdapterRDMA <name>
# set globally for all interfaces
Set-NetOffloadGlobalSetting -NetworkDirect Enabled
# observe
Get-SmbServerNetworkInterface
Get-SmbClientNetworkInterface
get-NetAdapterRDMA



# ssh keys
# add key to agent manually?
ssh-add ~/.ssh/work
[Environment]::SetEnvironmentVariable("GIT_SSH", "C:\Windows\System32\OpenSSH\ssh.exe", "Machine")


# docker engine (headless install)
# no config daemon.json was created? see:
# https://docs.docker.com/reference/cli/dockerd/#on-windows
# ls $env:programdata\docker\config\daemon.json
# no such config dir created. odd
Enable-WindowsOptionalFeature -Online -FeatureName containers –All -n
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V –All -n

# The 'dockerd' binary here only supports running Windows containers.
# https://github.com/ScoopInstaller/Main/blob/master/bucket/docker.json
scoop install docker docker-compose docker-buildx
dockerd --register-service
set-service -name docker -startuptype Automatic
start-service docker


# tailscale (headless install)
scoop install tailscale
reg import "C:\Users\chris\scoop\apps\tailscale\current\add-startup.reg"
restart-computer
tailscale up --auth-key=<auth key from web ui>  --unattended
tailscale set --auto-update


# containerd
# Note: you should probably use the sig-windows k8s scripts to install containerd for a k8s install
# Note: the scoop containerd does NOT appear to interfere with the docker install
scoop install containerd nerdctl
containerd --register-service
set-service -name containerd -startuptype Automatic
start-service containerd
