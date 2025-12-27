# testing: we expect to see little to no traffic on the server, using iftop or btm

# write: 24 gb/s (2944 MB) | read: 26 gb/s (3260 MB)
# across network to /tmp (ramdisk) on 66 Gigabit/s connection
sudo mkdir -p /mnt/tmp/speedtest
sudo fio --name=testfile --directory=/mnt/tmp/speedtest --size=2G --numjobs=16 --rw=write --bs=1000M --ioengine=libaio \
    --fdatasync=1 --runtime=30 --time_based --group_reporting --eta-newline=1s
sudo fio --name=testfile --directory=/mnt/tmp/speedtest --size=2G --numjobs=16 --rw=read --bs=1000M --ioengine=libaio \
    --fdatasync=1 --runtime=30 --time_based --group_reporting --eta-newline=1s

# res: 24 gigabit/s write, 26 gigabit/s read
sudo mkdir -p /mnt/q/speedtest
sudo fio --name=testfile --directory=/mnt/q/speedtest --size=2G --numjobs=16 --rw=write --bs=1000M --ioengine=libaio \
    --fdatasync=1 --runtime=30 --time_based --group_reporting --eta-newline=1s
sudo fio --name=testfile --directory=/mnt/q/speedtest --size=2G --numjobs=16 --rw=read --bs=1000M --ioengine=libaio \
    --fdatasync=1 --runtime=30 --time_based --group_reporting --eta-newline=1s