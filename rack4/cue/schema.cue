@experiment(try)

package rack4

import "list"

services: [Service=_]: {
	_group:     *Service | string
	_store:     *"$DATA/\(_group)" | string
	_homepage?: #Homepage
	_pangolin?: #Pangolin
	_traefik?:  #Traefik

	let _is_pangolin = _pangolin != _|_
	let _is_traefik = _traefik != _|_

	networks: [...string]
	if _is_pangolin {
		networks: list.Contains("newt")
	}
	if _is_traefik {
		networks: list.Contains("traefik")
	}

	_domain: string
	if _is_traefik && !_is_pangolin {
		_domain: *"\(Service).henn.dev" | string
	} else {
		_domain: *"\(Service).chenn.dev" | string
	}

	profiles: *[_group] | [...string]
	image:          string
	container_name: *Service | string
	restart:        *"unless-stopped" | string
	environment: {}
	volumes: [...string]
	expose: [...string]

	labels: {
		if _homepage != _|_ {
			_homepage_defaults: {
				group:       *"Arr" | #HomepageGroup
				name:        *Service | string
				icon:        *"\(Service).png" | string
				href:        *"https://\(_domain)" | string
				description: *"" | string
			}
			for k, v in (_homepage & _homepage_defaults) {
				(#HomepageLabels[k]): v
			}
		}
		if _traefik {
			"traefik.enable":                                   true
			"traefik.http.routers.\(Service).rule":             *"Host(`\(Service).henn.dev`)" | string
			"traefik.http.routers.\(Service).entrypoints":      *"websecure" | string
			"traefik.http.routers.\(Service).middlewares":      *"hdrs@file" | string
			"traefik.http.routers.\(Service).tls.certresolver": *"cf" | string
		}
		if _pangolin != _|_ {
			_pangolin_labels: {
				domain: "pangolin.public-resources.\(Service).full-domain"
				mode:   "pangolin.public-resources.\(Service).mode"
				name:   "pangolin.public-resources.\(Service).name"
				policy: "pangolin.public-resources.\(Service).policy"
				method: "pangolin.public-resources.\(Service).targets[0].method"
			}
			_pangolin_defaults: {
				domain: *_domain | string
				mode:   *"http" | #PangolinMode
				name:   *Service | string
				policy: *"member" | #PangolinPolicy
				method: *"http" | #PangolinMethod
			}
			for k, v in (_pangolin & _pangolin_defaults) {
				(_pangolin_labels[k]): v
			}
		}
	}
}

services: [=~"_db"]:    _DbService
services: [=~"_redis"]: _RdService

_DbService: {
	image: *"postgres:18-alpine" | string
	environment: {
		POSTGRES_DB:       string
		POSTGRES_USER:     string
		POSTGRES_PASSWORD: string
	}
	healthcheck: #DbHealth
	expose: ["5432", ...string]
	_group!: string
	_store:  *"$DATA/\(_group)" | string
	volumes: ["\(_store)/db:/var/lib/postgresql"]
}
#DbHealth: {
	test:     "pg_isready -q -U $${POSTGRES_USER} -d $${POSTGRES_DB}"
	interval: "5s"
	timeout:  "5s"
	retries:  10
}

_RdService: {
	image:       *"valkey/valkey:alpine" | string
	healthcheck: #RdHealth
	expose: ["6379", ...string]
	_group!: string
	_store:  *"$DATA/\(_group)" | string
	volumes: ["\(_store)/redis:/data"]
}
#RdHealth: {
	"test":     "valkey-cli ping"
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

#PangolinMethod: *"http" | "https" | "h2c"
#PangolinMode:   *"http" | "tcp" | "udp" | "ssh" | "rdp" | "vnc"
#PangolinPolicy: *"member" | "arr" | "chris"
#Pangolin: {
	domain: string
	mode:   #PangolinMode
	name:   string
	policy: #PangolinPolicy
	method: #PangolinMethod
}

#HomepageGroup: "Arr" | "AI" | "Infra" | "Development Tools"
#Homepage: {
	group:       #HomepageGroup
	name:        string
	icon:        string
	href:        string
	description: string
}
#HomepageLabels: {
	group:       "homepage.group"
	name:        "homepage.name"
	icon:        "homepage.icon"
	href:        "homepage.href"
	description: "homepage.description"
}
