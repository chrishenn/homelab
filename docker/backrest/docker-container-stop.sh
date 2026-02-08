#!/bin/bash

all_containers=$(docker ps --quiet | sort)

ignore_containers=$(
	docker ps --quiet \
		--filter "name=element" \
		--filter "name=glances" \
		--filter "name=grafana" \
		--filter "name=homepage" \
		--filter "name=it-tools" \
		--filter "name=kiwix" \
		--filter "name=markopolis" \
		--filter "name=ntfy" \
		--filter "name=reminiflux" \
		--filter "name=thelounge" \
		--filter "name=traefik" \
		--filter "name=watchtower" \
		--filter "name=whoami" |
		sort
)

pending_containers=$(comm -23 <(echo "$all_containers") <(echo "$ignore_containers"))

echo "Stopping docker containers..."

docker stop $pending_containers
