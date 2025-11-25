Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-ExecutionPolicy Bypass -Force
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name LongPathsEnabled -Value 1 -PropertyType DWORD -Force
Resize-Partition -DriveLetter "C" -Size (Get-PartitionSupportedSize -DriveLetter "C").SizeMax

iwr https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.5.0.0p1-Beta/OpenSSH-Win64.zip -outfile /openssh.zip
Expand-Archive /openssh.zip /openssh
& /openssh/OpenSSH-Win64/install-sshd.ps1
