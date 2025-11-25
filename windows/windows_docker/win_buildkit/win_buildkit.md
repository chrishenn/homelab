# win_buildkit

I believe that buildkit support has been built into window's docker distribution, so this early experimental stuff is
likely obsolete

---

buildkit experiments against early buildkit support for windows

refs
https://github.com/moby/buildkit/blob/master/docs/windows.md
https://docs.docker.com/build/guide/mounts/#add-a-cache-mount

```bash
you must use this unix-like path style under powershell right now

SHELL [ "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';" ]
RUN /Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command ls


interesting

SHELL ["cmd", "/S", "/C"]
RUN C:\ProgramData\chocolatey\bin\choco.exe install -y --allow-empty-checksums \
    cmake.portable --version=3.27.9
RUN /ProgramData/chocolatey/bin/choco.exe install -y --allow-empty-checksums \
    ninja


when running this under cmd, make damn sure you have an "=" between --params="/thing" or else cmd will interpret /thing as a
cmdline switch or as its own command. odd

RUN /ProgramData/chocolatey/bin/choco.exe install -y --allow-empty-checksums \
    git.install --params="/GitOnlyOnPath /NoGitLfs" --ia="/DIR=C:\GIT"
RUN /ProgramData/chocolatey/bin/choco.exe install -y --allow-empty-checksums \
    llvm --ia="/D=C:\LLVM"
```

---

buildkit binaries

```powershell
$version = "v0.14.1" # specify the release version, v0.13+
$arch = "amd64" # arm64 binary available too
curl.exe -LO https://github.com/moby/buildkit/releases/download/$version/buildkit-$version.windows-$arch.tar.gz
# there could be another `.\bin` directory from containerd instructions
# you can move those
mv bin bin2
tar.exe xvf .\buildkit-$version.windows-$arch.tar.gz
## x bin/
## x bin/buildctl.exe
## x bin/buildkitd.exe

# after the binaries are extracted in the bin directory
# move them to an appropriate path in your $Env:PATH directories or:
Copy-Item -Path ".\bin" -Destination "$Env:ProgramFiles\buildkit" -Recurse -Force
# add `buildkitd.exe` and `buildctl.exe` binaries in the $Env:PATH
$Path = [Environment]::GetEnvironmentVariable("PATH", "Machine") + `
    [IO.Path]::PathSeparator + "$Env:ProgramFiles\buildkit"
[Environment]::SetEnvironmentVariable( "Path", $Path, "Machine")
$Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + `
    [System.Environment]::GetEnvironmentVariable("Path","User")

# start the buildkit daemon
buildkitd.exe
```

set up networking cni

```powershell
$networkName = 'nat'

# the default one named `nat` should be available
$natInfo = Get-HnsNetwork -ErrorAction Ignore | Where-Object { $_.Name -eq $networkName }
if ($null -eq $natInfo) {
    throw "NAT network not found, check if you enabled containers, Hyper-V features and restarted the machine"
}
$gateway = $natInfo.Subnets[0].GatewayAddress
$subnet = $natInfo.Subnets[0].AddressPrefix

$cniConfPath = "$env:ProgramFiles\containerd\cni\conf\0-containerd-nat.conf"
$cniBinDir = "$env:ProgramFiles\containerd\cni\bin"
$cniVersion = "0.3.0"

# get the CNI plugins (binaries)
mkdir $cniBinDir -Force
curl.exe -LO https://github.com/microsoft/windows-container-networking/releases/download/v$cniVersion/windows-container-networking-cni-amd64-v$cniVersion.zip
tar xvf windows-container-networking-cni-amd64-v$cniVersion.zip -C $cniBinDir

$natConfig = @"
{
    "cniVersion": "$cniVersion",
    "name": "$networkName",
    "type": "nat",
    "master": "Ethernet",
    "ipam": {
        "subnet": "$subnet",
        "routes": [
            {
                "gateway": "$gateway"
            }
        ]
    },
    "capabilities": {
        "portMappings": true,
        "dns": true
    }
}
"@
Set-Content -Path $cniConfPath -Value $natConfig
```

add buildkitd as a service

```powershell
buildkitd `
--register-service `
--service-name buildkitd `
--containerd-cni-config-path="C:\Program Files\containerd\cni\conf\0-containerd-nat.conf" `
--containerd-cni-binary-dir="C:\Program Files\containerd\cni\bin" `
--debug `
--log-file="C:\Windows\Temp\buildkitd.log"

sc.exe config buildkitd depend= containerd
Set-Service -StartupType Automatic buildkitd
start-service buildkitd

# verify
buildctl debug info
# BuildKit: github.com/moby/buildkit v0.14.1 eb864a84592468ee9b434326cb7efd66f58555af
```

create a remote builder that uses the local buildkit daemon

```powershell
docker buildx create --name buildkit-exp --use --driver=remote npipe:////./pipe/buildkitd

# after the builder has already been created
docker buildx use buildkit-exp
```

verify

```powershell
docker buildx inspect

# platform: winmdows/amd64
# endpoint: named pipe

Name:          buildkit-exp
	Name:             buildkit-exp0
	Endpoint:         npipe:////./pipe/buildkitd
	Platforms:        windows/amd64
```

---

hello-world example

```powershell
mkdir sample_dockerfile
cd sample_dockerfile
Set-Content Dockerfile @"
FROM mcr.microsoft.com/windows/nanoserver:ltsc2022
USER ContainerAdministrator
COPY hello.txt C:/
RUN echo "Goodbye!" >> hello.txt
CMD ["cmd", "/C", "type C:\\hello.txt"]
"@
Set-Content hello.txt @"
Hello from BuildKit!
This message shows that your installation appears to be working correctly.
"@

##
docker login

docker buildx build --push -t christianhenn/hello-buildkit .

docker run christianhenn/hello-world
```

---

build and load into local docker

```powershell
docker buildx build -t localhost/win_builder --load

# progress=plain to see printed output from builder
#docker buildx build -t localhost/agent-build-win-native --load --progress=plain .
```

```powershell
$env:SRC_DIR = "C:\home\chris\Documents\agent_current\endpoint-agent"

./buildenv.ps1 build
./buildenv.ps1 attach
./buildenv.ps1 compile_make_pkgs
```

---

```powershell
Set-Content Dockerfile @"
FROM mcr.microsoft.com/windows/nanoserver:ltsc2022

ADD https://github.com/kubernetes-sigs/windows-testing/raw/3fea3d48ea8337b2aaca755c1d719e34b45f46b9/images/busybox/busybox.exe /bin/busybox.exe

USER ContainerAdministrator

RUN net user testuser /ADD /ACTIVE:yes
USER testuser
RUN echo "%USERNAME%"
"@
```

build the image from the dockerfile

```powershell
buildctl.exe build --output type=image,name=docker.samfira.com/test,push=false `
  --progress plain `
  --frontend=dockerfile.v0  `
  --local context=. `
  --local dockerfile=.
```

now how to run it
ctr ships with containerd

```powershell
ctr run --cni -rm
```

stackoverflow

```
buildctl build
	--frontend dockerfile.v0 \
	--opt build-arg:VERSION=$BUILD_VERSION \
	--opt context=my-image:$BUILD_VERSION \
	--local context=. \
	--local dockerfile=. \
	--output type=docker,dest=./my-image_$BUILD_VERSION.tar,name=my-image:$BUILD_VERSION

docker load --input my-image.tar
```

It looks like you can either export as tar, then docker load, or you can push to registry. I don't have a local registry set up

quoth he:
The resulting image is in the `buildkit` namespace. You should be able to see it by running:

```
ctr -n buildkit i ls
```

Or:

```powershell
nerdctl.exe -n buildkit images
```

Just make sure you're connecting to the same containerd named pipe as buildkitd is using. Sorry for the confusion.
this image is in LLB, the intermediate compiled repr that buildkit uses to solve dep graphs to build your shit.

---
