#!/bin/bash

parallel=16
pct list | grep stopped | awk '{print $1}' |
	while read container; do
		while [ $(jobs -pr | wc -l) -ge ${parallel} ]; do
			sleep 0.5
		done
		# check if onboot yes/no
		onboot=$(pct config $container | grep onboot | awk '{print $2}')
		if [ "$onboot" == "1" ]; then
			pct start $container &
			sleep 0.5
		fi
	done
