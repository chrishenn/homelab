#!/bin/bash

/home/cyhyraeth/.local/bin/docker-container-start.sh

sleep 30

ntfy publish \
	--delay=10s \
	--title="Server backup complete" \
	--message="Restarting docker containers. Server should now be available again." \
	--icon="https://archlinux.org/static/favicon.png" \
	https://ntfy.domain.tld/server-status
