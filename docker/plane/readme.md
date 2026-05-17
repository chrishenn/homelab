initial boot still incredibly difficult to debug
with a working env setup, the processes all came up - then couldn't log in until the migrator exited A MINUTE LATER?!
WITH NO INDICATION THAT THE SERVER WAS WAITING FOR ANYTHING. NO SUPPORT FOR THE LOG_LEVEL FLAG?!

you need to sit at the error page "looks like plane didn't start up correctly!" for 90 seconds to 5 minutes
very helpful error message - and it's a complete lie. Great job. There will be no errors in the logs because there are
no errors - you just need to wait 5 minutes. tremendous.

plane | 2026-06-12 07:34:02,694 INFO success: worker entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:39:24,714 INFO exited: migrator (exit status 0; expected)

WHAT IN TARNATION ARE WE MIGRATING FOR 5 MINUTES ON AN EMPTY INSTANCE!?! WHAT IS HAPPENING

---

access from multiple urls does technically work though it's a bit glitchy

local OIDC is paywalled

---

plane | 2026-06-12 07:18:02,355 INFO Set uid to user 1000 succeeded
plane | 2026-06-12 07:18:02,357 INFO supervisord started with pid 71
plane | 2026-06-12 07:18:03,361 INFO spawned: 'migrator' with pid 72
plane | 2026-06-12 07:18:03,363 INFO spawned: 'monitor' with pid 73
plane | 2026-06-12 07:18:03,365 INFO spawned: 'api' with pid 74
plane | 2026-06-12 07:18:03,367 INFO spawned: 'space' with pid 76
plane | 2026-06-12 07:18:03,369 INFO spawned: 'automation-consumer' with pid 78
plane | 2026-06-12 07:18:03,371 INFO spawned: 'beat' with pid 84
plane | 2026-06-12 07:18:03,373 INFO spawned: 'email' with pid 88
plane | 2026-06-12 07:18:03,375 INFO spawned: 'iframely' with pid 94
plane | 2026-06-12 07:18:03,377 INFO spawned: 'live' with pid 98
plane | 2026-06-12 07:18:03,379 INFO spawned: 'outbox-poller' with pid 100
plane | 2026-06-12 07:18:03,381 INFO spawned: 'proxy' with pid 112
plane | 2026-06-12 07:18:03,383 INFO spawned: 'silo' with pid 117
plane | 2026-06-12 07:18:03,385 INFO spawned: 'worker' with pid 119
plane | 2026-06-12 07:18:05,187 INFO success: migrator entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:18:05,187 INFO success: monitor entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:18:05,187 INFO success: api entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:18:05,187 INFO success: space entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:18:05,187 INFO success: automation-consumer entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:18:05,187 INFO success: beat entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:18:05,187 INFO success: email entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:18:05,187 INFO success: iframely entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:18:05,187 INFO success: live entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:18:05,187 INFO success: outbox-poller entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:18:05,187 INFO success: proxy entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:18:05,187 INFO success: silo entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:18:05,188 INFO success: worker entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
plane | 2026-06-12 07:19:33,789 INFO exited: migrator (exit status 0; expected)
