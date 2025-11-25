FROM mcr.microsoft.com/windows/servercore:ltsc2022 as buildtools
SHELL ["cmd", "/S", "/C"]

# install visual studio buildtools.
ENV VSINSTALLDIR="C:\\BuildTools"
RUN curl.exe -LO "https://download.visualstudio.microsoft.com/download/pr/11917f82-1030-4dda-a768-f0da3c4623a9/9c46bb75e959df411b26cd8bc871a53b495010f4e868fcc509f9bb26756cb311/vs_BuildTools.exe" \
    && echo Installing Visual Studio (this will take a long time with no output) \
    && (start /w vs_BuildTools.exe --wait --norestart --quiet --nocache \
        --installPath %VSINSTALLDIR% \
        --add "Microsoft.VisualStudio.Workload.MSBuildTools" \
        --add "Microsoft.VisualStudio.Component.VC.Tools.x86.x64" \
        --add "Microsoft.VisualStudio.Component.VC.Tools.ARM64" \
        --add "Microsoft.VisualStudio.Component.Windows11SDK.26100" \
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) \
    && echo Import-Module "$env:VSINSTALLDIR\\Common7\\Tools\\Microsoft.VisualStudio.DevShell.dll" > "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\profile.ps1" \
    && echo Enter-VsDevShell -VsInstallPath $env:VSINSTALLDIR -SkipAutomaticLocation -Arch $env:PROCESSOR_ARCHITECTURE -HostArch $env:PROCESSOR_ARCHITECTURE >> "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\profile.ps1" \
    && echo Cleaning up \
    && del /q vs_BuildTools.exe \
    && del /s /q "%TEMP%\\*" >nul 2>&1 \
    && rmdir /s /q "C:\\ProgramData\\Package Cache"

# this will launch developer shell, as the launch command is now in profile.ps1
CMD ["powershell.exe", "-ExecutionPolicy", "Bypass"]


FROM mcr.microsoft.com/windows/servercore:ltsc2022 as buildtools_2
SHELL [ "powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';" ]

# install visual studio buildtools.
ADD https://aka.ms/vs/17/release/vs_BuildTools.exe "C:\TEMP\vs_buildtools.exe"
RUN & C:\TEMP\vs_buildtools.exe \
    --quiet --wait --norestart --nocache \
    --path install=C:\BuildTools \
    --add "Microsoft.VisualStudio.Workload.VCTools" --includeRecommended \
    --add "Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools" \
    --add "Microsoft.VisualStudio.Workload.MSBuildTools" \
    --add "Microsoft.VisualStudio.Workload.UniversalBuildTools" \
    --add "Microsoft.VisualStudio.Component.VC.ATLMFC"; \
    rm -r C:\TEMP


FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS buildtools_3
SHELL ["cmd", "/S", "/C"]

# install visual studio buildtools
ADD https://aka.ms/vs/17/release/vs_BuildTools.exe /TEMP/vs_buildtools.exe
RUN C:\TEMP\vs_buildtools.exe \
    --quiet --wait --norestart --nocache \
    --installPath "C:\BuildTools" \
    --add "Microsoft.VisualStudio.Workload.VCTools" --includeRecommended \
    --add "Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools" \
    --add "Microsoft.VisualStudio.Workload.MSBuildTools" \
    --add "Microsoft.VisualStudio.Workload.UniversalBuildTools" \
    --add "Microsoft.VisualStudio.Component.VC.ATLMFC" \
    && rmdir /s /q C:\TEMP


# launch powershell with dev tools (assumes default install path)
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "-host_arch=amd64", "-arch=amd64", "&&", \
                "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]

# launch powershell with dev tools - when powershell not on path
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "-host_arch=amd64", "-arch=amd64", "&&", \
            "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
