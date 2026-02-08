#!/bin/sh
set -ex

cd "$REPO_MACHINE"
echo "$SVCS" | tr ',' '\n' | while read svc; do
	# todo: update this to use fnox
	op run --env-file .env.secrets --no-masking -- docker compose down $svc
	op run --env-file .env.secrets --no-masking -- docker compose build --push $svc
	op run --env-file .env.secrets --no-masking -- docker compose up -d $svc
done
