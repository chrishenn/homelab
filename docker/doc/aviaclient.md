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

So as a stopgap I threw this together. No icon here, though I'm sure one is included in the install dir

```desktop
[Desktop Entry]
Comment=
Exec=/var/home/chris/.local/share/soar/packages/avia-1.8.4-8f08685ae92b/avia --force-server=https://stoat.chenn.dev
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
ref: https://github.com/pkgforge-dev/Discord-AppImage

Soar update will break this absolute path, obv
