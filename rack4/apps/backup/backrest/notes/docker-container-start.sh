#!/bin/bash

stopped_containers=$(docker ps --quiet --filter "status=exited" | sort)

echo "Starting docker containers..."

[[ -z $stopped_containers ]] ||
	docker start $stopped_containers
