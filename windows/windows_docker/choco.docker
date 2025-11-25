FROM mcr.microsoft.com/windows/servercore:ltsc2022 as chocotools
SHELL [ "powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';" ]

# install tools with chocolatey
ENV chocolateyUseWindowsCompression false
RUN iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); \
    choco feature disable -n showDownloadProgress; \
    choco feature enable -n allowGlobalConfirmation

RUN choco install -y --allow-empty-checksums cmake.portable --version=3.27.9
RUN choco install -y --allow-empty-checksums ninja
RUN choco install -y --allow-empty-checksums git.install \
    --params "'/GitOnlyOnPath /NoGitLfs /NoShellIntegration'" --ia "'/DIR=C:\GIT'"
RUN choco install -y --allow-empty-checksums llvm --ia "'/D=C:\LLVM'"

COPY --from=chocotools "C:\ProgramData\chocolatey\lib\cmake.portable\tools\cmake-3.27.9-windows-x86_64" "C:\CMAKE"
COPY --from=chocotools "C:\ProgramData\chocolatey\lib\ninja\tools\ninja.exe" "C:\NINJA\ninja.exe"
COPY --from=chocotools "C:\LLVM" "C:\LLVM"
COPY --from=chocotools "C:\GIT" "C:\GIT"

RUN setx /M PATH $("$Env:PATH" + ';C:\CMAKE\bin' + ';C:\NINJA' + ';C:\LLVM\bin' + ';C:\GIT\cmd')
