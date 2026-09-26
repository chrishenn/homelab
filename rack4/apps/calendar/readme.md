# calendar

These all look nice but are donk butt to boot and use

--

None of them can do everything below:

- per-event coloring
- event repeat rules can spec 'third monday of month' as well as 'third day of month'
- hotkeys 'w' for week and 'm' for month
- create an all-day event from month view by clicking on a day
- android app that works

Google calendar has added a 'booking pages' calendly-like feature recently, and none of them do that either. Though
that's not a deal-breaker, it would be nice.

Interesting to note that google login for any of these will typically only work on chrome, and not zen.

There were a slew of php-based projects, that I will not consider under any circumstances.

Additional general problems:

- horrible jank and slop
- crap documentation
- simple sysadmin processes that are unnecessarily broken and dumb (too many containers, migrations and web pages
  distributed as unchecked scripts and files for no reason, etc)

Specific problems:

- SilentSuite
  - expects you to use their frontend and connect it (manually!) to your backend on every login - meaning
      you would want to hack together a self-hosting setup for the frontend yourself
  - initial e2e decrypt is slow (~20sec)

- Keeper
  - only does calendar muxing
    1. one-way sync a calendar into another calendar, copying at least the time block from one to the other
    2. mux multiple source calendars into a unified .ics stream for consuming from a webdav viewer
