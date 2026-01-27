# AI audio: noise filtering on windows

- Reaper is too heavy to also play csgo
    - on intel 8700k with a GTX 1080
- Probably figure out a better way to host the VST plugin that's lighter-weight
    - there is some "VST Server" plugin that I had tried at some point
- SAR is super janky and bad for device routing
- Probably figure out a better way to route virtual audio devices
    - voicemeeter ?
    - equalizerapo ?
    - is there no graphical router like there is on linux? I'd like an FL-studio style frontend for creating and routing
      virtual devices

---

### Working recipe (although it introduces lag/stutter due to cpu load and is real janky):

- install SAR Synchronous Audio Router. The latest release does not work (drivers not signed). Use the 13.1 version in
  apps folder.

- install reaper. Point reaper to SAR for default audio interface. SAR needs an ASIO interface to run on top of -
  ASIO4ALL will work if you don’t have an ASIO driver-device.

- Create a recording device in SAR config. Create a track in reaper. Hit the record button on the track to arm it.
  Right-click the record button and choose mic input. Add fx to track as needed. Hit routing button on the track and
  route the track to hardware output, which is the SAR recording device we created. The SAR recording device should show
  in windows sounds menu as a device.

- VoiceFX requires visual studio distrib and Turing or later gpu. Install the correct nvidia sdk for voice effects.
  Install the VST3 version of VoiceFX plugin. The plugin will silently fail if dependencies are not present. Also may
  need an env var to be present, which may need a restart to show up.

- Per-application routing rules in SAR seem to not work well (or at all). However, the default SAR devices set in
  windows sounds seem to stick. If many SAR devices are made and removed, they seem to stick around with the wrong name
  when they shouldn’t. At this point, remove all SAR devices from SAR config. Close reaper. Uninstall SAR. Reboot.
  Reinstall SAR. Reboot. Reconfigure in reaper.
