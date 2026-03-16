# Opencloud

The styling and overall jank are the best of these document servers with collabora integration. However, configuration
tasks that should be effortless are ... very ... not.

this project feels like it was written by aliens

- double-click does not open a file
- shift+click with multi-select, but ctrl-click does not work
- configuration is a disaster - a million settings across multiple files, with terrible defaults and nonsensical names
- simple things are made impossibly difficult - keyclock IDP integration is explicitly spelled out, yet OIDC is impossible?
- doc examples mix bash-style and yaml-style key-value pairs - impossible to use verbatim, poorly explained
- you have to manually set file permissions after the container boots
- the wopiserver and document server have to bind to two urls, even though they're served in the same container
    - necessitates the two-tiered network config in collabora - and net.frame_ancestors is deprecated - replace soon

I cannot tell if pocketid is even integratable - despite the documentation on the topic being EXTREMELY long. Couldn't
get it working. Gave up.
