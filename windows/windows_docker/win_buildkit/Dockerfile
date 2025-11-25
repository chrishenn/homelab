FROM mcr.microsoft.com/windows/servercore:ltsc2022
SHELL [ "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';" ]

RUN iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); \
    choco feature disable -n showDownloadProgress; \
    choco feature enable -n allowGlobalConfirmation

SHELL ["cmd", "/S", "/C"]
RUN C:\ProgramData\chocolatey\bin\choco.exe install -y --allow-empty-checksums \
    cmake.portable --version=3.27.9
RUN C:\ProgramData\chocolatey\bin\choco.exe install -y --allow-empty-checksums \
    ninja
RUN C:\ProgramData\chocolatey\bin\choco.exe install -y --allow-empty-checksums \
    git.install --params="/GitOnlyOnPath /NoGitLfs" --ia="/DIR=C:\GIT"
RUN C:\ProgramData\chocolatey\bin\choco.exe install -y --allow-empty-checksums \
    llvm --ia "/D=C:\LLVM"
