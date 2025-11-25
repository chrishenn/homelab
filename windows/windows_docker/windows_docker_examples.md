example windows dockerfile

```dockerfile
FROM mcr.microsoft.com/windows/servercore:2004 as INSTALLER
SHELL [ "powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';" ]

RUN Invoke-WebRequest -Uri https://curl.haxx.se/windows/dl-7.72.0_5/curl-7.72.0_5-win64-mingw.zip -outfile /curl.zip; \
    Expand-Archive /curl.zip -DestinationPath /; \
    Move-Item curl-7.72.0-win64-mingw curl

RUN Invoke-WebRequest -Uri https://github.com/git-for-windows/git/releases/download/v2.28.0.windows.1/MinGit-2.28.0-64-bit.zip -outfile /MinGit.zip; \
    Expand-Archive /MinGit.zip -DestinationPath /MinGit;

RUN Invoke-WebRequest -Uri https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.1.0.0p1-Beta/OpenSSH-Win64.zip -outfile /openssh.zip; \
    Expand-Archive /openssh.zip -DestinationPath /;

# RUN {CURL_LINE_WIN}/known_hosts -o known_hosts; \
#    {CURL_LINE_WIN}/clone_key -o clone_key

RUN Invoke-WebRequest https://aka.ms/vs/16/release/vs_buildtools.exe -outfile /vs_buildtools.exe
RUN /vs_buildtools.exe --quiet --wait --norestart --nocache \
    --installPath C:\BuildTools \
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
    --add Microsoft.VisualStudio.Component.VC.v141.x86.x64

RUN /vs_buildtools.exe --quiet --wait --norestart --nocache \
    --installPath C:\BuildTools \
    --add Microsoft.VisualStudio.Component.Windows10SDK.18362

ENV PYTHON_VERSION 3.8.6
ENV PYTHON_RELEASE 3.8.6

RUN $url = ('https://www.python.org/ftp/python/{0}/python-{1}-amd64.exe' -f $env:PYTHON_RELEASE, $env:PYTHON_VERSION); \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'python.exe'; \
	Write-Host 'Installing ...'; \
	Start-Process python.exe -Wait \
		-ArgumentList @( \
			'/quiet', \
			'InstallAllUsers=1', \
			'TargetDir=C:\Python', \
			'PrependPath=1', \
			'Shortcuts=0', \
			'Include_doc=0', \
			'Include_pip=0', \
			'Include_test=0' \
		); \
	$env:PATH = [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::Machine); \
	Write-Host 'Verifying install ...'; \
	Write-Host '  python --version'; python --version; \
	Write-Host 'Removing ...'; \
	Remove-Item python.exe -Force; \
	Write-Host 'Complete.'

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 20.2.3
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/fa7dc83944936bf09a0e4cb5d5ec852c0d256599/get-pip.py
ENV PYTHON_GET_PIP_SHA256 6e0bb0a2c2533361d7f297ed547237caf1b7507f197835974c0dd7eba998c53c

RUN Write-Host ('Downloading get-pip.py ({0}) ...' -f $env:PYTHON_GET_PIP_URL); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $env:PYTHON_GET_PIP_URL -OutFile 'get-pip.py'; \
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:PYTHON_GET_PIP_SHA256); \
	if ((Get-FileHash 'get-pip.py' -Algorithm sha256).Hash -ne $env:PYTHON_GET_PIP_SHA256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	Write-Host ('Installing pip=={0} ...' -f $env:PYTHON_PIP_VERSION); \
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		('pip=={0}' -f $env:PYTHON_PIP_VERSION) \
	; \
	Remove-Item get-pip.py -Force; \
	Write-Host 'Verifying pip install ...'; \
	pip --version; \
	Write-Host 'Complete.'

RUN pip install buildbot-worker

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-nanoserver-2004
SHELL [ "pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';" ]

COPY --from=INSTALLER [ "C:/MinGit", "C:/git" ]
COPY --from=INSTALLER [ "C:/OpenSSH-Win64", "C:/openssh" ]
COPY --from=INSTALLER [ "C:/Python", "C:/Python" ]

RUN New-Item -Path $HOME/.ssh/ -ItemType "Directory"
# COPY --from=INSTALLER [ "C:/known_hosts", "C:/Users/ContainerUser/.ssh/known_hosts" ]
# COPY --from=INSTALLER [ "C:/clone_key", "C:/Users/ContainerUser/.ssh/id_rsa" ]

WORKDIR C:/Users/ContainerUser

RUN setx Path "$Env:Path`;C:\git\cmd`;C:\openssh`;C:\Python`;C:\Python\Scripts"; \
    setx GIT_SSH "C:\openssh\ssh.exe"; \
    echo 'buildbot-worker create-worker . \"${Env:BUILDMASTER}:${Env:BUILDMASTER_PORT}\" \"$Env:WORKERNAME\" \"$Env:WORKERPASS\";' >> start.ps1; \
    echo 'Start-Process buildbot-worker -Wait -ArgumentList \"start\",\"--nodaemon\",\".\"' >> start.ps1;

ENTRYPOINT [ "pwsh", "start.ps1" ]
```

note how they quote --params to choco install. double, then single quotes

```Dockerfile
FROM mcr.microsoft.com/windows/servercore:1903
LABEL maintainer "Fluentd developers <fluentd@googlegroups.com>"
LABEL Description="Fluentd docker image" Vendor="Fluent Organization" Version="1.11.5"

# Do not split this into multiple RUN!
# Docker creates a layer for every RUN-Statement
RUN powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

# Fluentd depends on cool.io whose fat gem is only available for Ruby < 2.5, so need to specify --platform ruby when install Ruby > 2.5 and install msys2 to get dev tools
RUN choco install -y ruby --version 2.6.5.1 --params "'/InstallDir:C:\ruby26'" \
&& choco install -y msys2 --version 20200903.0.0 --params "'/NoPath /NoUpdate /InstallDir:C:\ruby26\msys64'"
RUN refreshenv \
&& ridk install 2 3 \
&& echo gem: --no-document >> C:\ProgramData\gemrc \
&& gem install cool.io -v 1.5.4 --platform ruby \
&& gem install oj -v 3.3.10 \
&& gem install json -v 2.2.0 \
&& gem install fluentd -v 1.11.5 \
&& gem install win32-service -v 1.0.1 \
&& gem install win32-ipc -v 0.7.0 \
&& gem install win32-event -v 0.6.3 \
&& gem install windows-pr -v 1.2.6 \
&& gem sources --clear-all

# Remove gem cache and chocolatey
RUN powershell -Command "Remove-Item -Force C:\ruby26\lib\ruby\gems\2.6.0\cache\*.gem; Remove-Item -Recurse -Force 'C:\ProgramData\chocolatey'"

COPY fluent.conf /fluent/conf/fluent.conf

ENV FLUENTD_CONF="fluent.conf"

EXPOSE 24224 5140

ENTRYPOINT ["cmd", "/k", "fluentd", "-c", "C:\\fluent\\conf\\fluent.conf"]
```
