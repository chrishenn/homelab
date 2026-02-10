#!/bin/sh
set -ex

# set CRON_CMD command to run on CRON_SCHEDULE (default '0 0 * * *').
# set RUN_NOW=1 to run once immediately, then run on CRON_SCHEDULE

# docker config copied from runtime machine (docker host), not build machine
mkdir -p /root/.docker
cp /config.json /root/.docker/config.json

# validate CRON_CMD is supplied
if [ -z ${CRON_CMD+x} ]; then
	echo "ERROR: CRON_CMD is unset"
	exit 1
fi

# render crontab
tee crontab <<-END
	${CRON_SCHEDULE:-"0 0 * * *"} $CRON_CMD
END

# run then exit. The container will restart, keeping the "now" file, therefore ignoring RUN_NOW on second start
if [ ${RUN_NOW:-0} = 1 -a ! -f now ]; then
	touch now

	# CRON_CMD can be a binary, script file, or a single command
	eval "$CRON_CMD"
	exit $?
fi

exec "$@"
