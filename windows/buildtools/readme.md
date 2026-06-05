# buildtools

buildtools for windows

- build rust apps with msvc
- build windows apps in windows containers
- install tools via the accursed vs_buildtools (beats the vs gui installer. but still terrible)

---

MSVC toolchain for rust

```cmd
set "url=https://aka.ms/vs/17/release/vs_BuildTools.exe"
curl -L %url% -o tools.exe ^
    && (start /w tools.exe --wait --norestart --quiet --nocache ^
        --add "Microsoft.VisualStudio.Component.VC.Tools.x86.x64" ^
        --add "Microsoft.VisualStudio.Component.Windows11SDK.26100" ^
        || IF "%ERRORLEVEL%"=="3010" EXIT 0)
echo Exit code 0 indicates success ^
    & echo Exited with code: %errorlevel%
rm tools.exe
```
