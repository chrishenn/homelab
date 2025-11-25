# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2022
SHELL [ "powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';" ]

WORKDIR /
USER ContainerAdministrator

# install tools
RUN Set-ExecutionPolicy Bypass; irm get.scoop.sh -o 'install.ps1'; .\install.ps1 -RunAsAdmin; rm install.ps1
RUN scoop install git@2.47.1
RUN scoop install aria2; scoop config aria2-warning-enabled false
RUN scoop install llvm@19.1.4

RUN scoop bucket add versions
RUN scoop install python311
RUN python -m pip install --upgrade pip sphinx

# install build tools here #

# set project folder safe
RUN mkdir C:\project
RUN git config --global --add safe.directory C:/project

# launch buildtools dev shell here #
