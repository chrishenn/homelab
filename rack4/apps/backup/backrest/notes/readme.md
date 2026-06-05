# backrest docker

example of how to use backup hook scripts to do docker operations during a backup
the use case is:

- you're backing up a folder that's mounted into docker container
- backrest can stop that container
- backrest snapshots the folder
- backrest restarts the container

I think the idea is that you don't want backrest snapshotting the folder at the same time some container is writing to
it

Note that I can use offen/docker-volume-backup to do essentially the same thing, but it could be nice to have all
backups defined in the backrest GUI
