# Windows Terminal Install with Custom Settings

Note: probably prefer to install this using the scoop manifest `wt` from chrishenn/scoops
Note: not sure if this python logic is at feature parity with the scoop bucket

---

To connect to remote windows machine and install windows-terminal, scoop, and custom settings:

```bash
just deploy
```

At the root of the settings file:

```json5
{
  multiLinePasteWarning: false,
  confirmCloseAllTabs: false,
}
```

Add git bash profile to settings.json under "profiles.list"

```json5
{
  commandline: "C:\\Program Files\\Git\\bin\\bash.exe",
  guid: "{b0f5ce57-a6d6-46d8-bc20-38b0b769789a}",
  hidden: false,
  name: "Git Bash",
}
```

---

note: pyinfra is totally incompatible with windows
