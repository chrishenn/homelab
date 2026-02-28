# Seafile

## Summary 

This stack technically "works", in the sense that all the parts can find each other, and are usable from the internet.
That being said:
  - given that this is a huge pile of jank, I can't imagine putting sensitive docs on this server
  - It feels like all of these fileserver projects are stuck in 2012
  - This sort of unecessary garbage is why sysadmin was a full-time job. IS a full-time job
  - WEBDAV.ORG IS HTTP-ONLY!!?? ARE YOU KIDDING ME <-- this is exactly what I'm talking about. Why would you use this?

## deploy

NOTE: WEBDAV SERVER HAS NO PASSWORD BY DEFAULT!! HAVE TO SET THE WEBDAV PASSWORD MANUALLY IN THE UI!!
sudo chmod -R 777 /mnt/k/docker/seafile/data/seafile/conf
manually add configuration/secrets

The env vars are obviously a dumpster fire. Make sure you meticulously find all the stuff that needs change for your 
hosting domain, storage, etc

## problems

- seadoc hits pangolin SSO when opening a doc - same problem as nextcloud
  - mitigated: put only the /accounts, /sys routes behind SSO
- seafile clients don't support custom headers, so auth headers through pangolin are no-go
  - mitigated: the mobile browser editing experience (realtime collab) is quite good for sdoc/collabora
- awful behavior caching settings on disk. This why configuration isn't code, people.
- settings files have secrets in plaintext, requiring a manual step to paste secrets into them
- seasearch dedicated docs site is completely broken
  - https://seasearch-manual.seafile.com/config/
- no obvious way to test the SMTP server setup
- webdav passwords must be less than 30 chars long. CMON PEOPLE WHAT ARE WE DOING
- seasearch doesn't react to file add/change, so you have to wait for interval for a rescan (default 10m) ?
  - theres a goofy "watch files" button in the UI for a library. What does that DO!?
- webdav basic auth is broken - have to put basic auth credentials directly into the url to access server
  - https://user:pass@seafile.chenn.dev/dav

## gripes

- UI is generally broken, ugly, and janky. Nothing works consistently.
- webdav server has no password by default? are we serious right now?
- collabora is also janky and BARELY works
- figured out how to match an OIDC user by email - not documented. Had to mess around with it manually :/
- not sure why I would need a dedicated server proc/container to write log files, handle thumbnails?

## positives

- comes up and goes down MUCH faster than nextcloud - huge for sysadmin QOL
- native markdown editing (without seadoc, even) is enough to replace google docs for me