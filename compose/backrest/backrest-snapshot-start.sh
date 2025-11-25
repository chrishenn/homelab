#!/bin/bash

ntfy publish \
	--title="Starting server backup" \
	--message="Stopping docker containers for backup. Server may be temporarily unavailable." \
	--icon="https://archlinux.org/static/favicon.png" \
	https://ntfy.domain.tld/server-status

sleep 30

/home/cyhyraeth/.local/bin/docker-container-stop.sh
