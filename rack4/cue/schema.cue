@experiment(try)

package rack4

import "list"

#HomepageGroup:  "Arr" | "AI" | "Infra" | "Development Tools"
#PangolinPolicy: *"member" | "arr" | "chris"

services: [Service=_]: {
	let _traefik = list.Contains(networks, "traefik")
	let _pangolin = list.Contains(networks, "newt")

	_domain: string
	if _traefik && !_pangolin {
		_domain: *"\(Service).henn.dev" | string
	} else {
		_domain: *"\(Service).chenn.dev" | string
	}

	_group: *Service | string
	_store: *"$DATA/\(_group)" | string

	profiles: *[_group] | [...string]
	image:          string
	container_name: *Service | string
	restart:        *"unless-stopped" | string
	environment: {}
	volumes: [...string]
	networks: [...string]
	expose: [...string]

	labels: {
		_hgroup="homepage.group"?: #HomepageGroup
		if _hgroup != _|_ {
			"homepage.group":        #HomepageGroup
			"homepage.name":         *Service | string
			"homepage.icon":         *(Service + ".png") | string
			"homepage.href":         *("https://" + _domain) | string
			"homepage.description"?: string
		}
		if _traefik {
			"traefik.enable":                                             true
			"traefik.http.routers.\(Service).rule":                       *"Host(`\(Service).henn.dev`)" | string
			"traefik.http.routers.\(Service).entrypoints":                *"websecure" | string
			"traefik.http.routers.\(Service).middlewares":                *"hdrs@file" | string
			"traefik.http.routers.\(Service).tls.certresolver":           *"cf" | string
			"traefik.http.services.\(Service).loadbalancer.server.port"?: int
		}
		if _pangolin {
			"pangolin.public-resources.\(Service).name":              *Service | string
			"pangolin.public-resources.\(Service).full-domain":       *_domain | string
			"pangolin.public-resources.\(Service).mode":              *"http" | string
			"pangolin.public-resources.\(Service).targets[0].method": *"http" | string
			"pangolin.public-resources.\(Service).targets[0].port"?:  int
			"pangolin.public-resources.\(Service).policy":            #PangolinPolicy
		}
	}
}

services: [=~"_db"]:    _PGService
services: [=~"_redis"]: _RedisService

_PGService: {
	image:       *"postgres:18-alpine" | string
	environment: {
		POSTGRES_DB: string
		POSTGRES_USER: string
		POSTGRES_PASSWORD: string
	}
	healthcheck: #PGHealth
	expose: ["5432", ...string]
	_group!: string
	_store: *"$DATA/\(_group)" | string
	volumes: ["\(_store)/db:/var/lib/postgresql"]
}
#PGHealth: {
	test:     "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"
	interval: "5s"
	timeout:  "5s"
	retries:  10
}

_RedisService: {
	image:       *"valkey/valkey:alpine" | string
	healthcheck: #RedisHealth
	expose: ["6379", ...string]
	_group!: string
	_store: *"$DATA/\(_group)" | string
	volumes: ["\(_store)/redis:/data"]
}
#RedisHealth: {
	"test":     "redis-cli ping"
	"interval": "5s"
	"timeout":  "5s"
	"retries":  10
}

_gpu: {
	runtime: "nvidia"
	deploy: resources: reservations: devices: [{
		driver: "nvidia"
		count:  "all"
		capabilities: ["gpu"]
	}]
}
