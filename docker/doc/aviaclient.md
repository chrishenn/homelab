# aviaclient

Installed the zip from github using soar. Binary is put on path by soar, but you need to launch using the absolute path
of the folder as a param. Otherwise the app launches but the window is blank.

```bash
# either
cd /var/home/chris/.local/share/soar/packages/avia-1.8.4-8f08685ae92b
./avia

# or
avia -- /var/home/chris/.local/share/soar/packages/avia-1.8.4-8f08685ae92b
```

So as a stopgap I threw this together

```desktop
[Desktop Entry]
Comment=
Exec=/var/home/chris/.local/share/soar/packages/avia-1.8.4-8f08685ae92b/avia -- %u
Name=avia
NoDisplay=false
Path=
PrefersNonDefaultGPU=false
StartupNotify=true
Terminal=false
TerminalOptions=
Type=Application
X-KDE-SubstituteUID=false
X-KDE-Username=
```

I'm sure there's a way to get soar to auto-package this correctly - or maybe I just need to build an appimage?

Soar update will break this absolute path, obv
