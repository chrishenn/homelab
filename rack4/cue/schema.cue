package rack4

import "list"

#HomepageGroup:  "Arr" | "AI"
#PangolinPolicy: *"member" | "arr" | "chris"

services: [Service=_]: {
	profiles: *[Service] | [...string]
	image:          string
	container_name: *Service | string
	restart:        *"unless-stopped" | string
	environment: {}
	volumes: [...string]
	networks: [...string]
	expose: [...string]

	_traefik?: bool
	if _traefik != _|_ if _traefik == true {
		networks: list.Contains("traefik")
		networks: *["traefik"] | [...string]
	}
	_pangolin?: bool
	if _pangolin != _|_ if _pangolin == true {
		networks: list.Contains("newt")
		networks: *["newt"] | [...string]
	}

	_domain: *"\(Service).chenn.dev" | string

	labels: {
		_hgroup="homepage.group"?: #HomepageGroup
		if _hgroup != _|_ {
			"homepage.group"!:       #HomepageGroup
			"homepage.name":         *Service | string
			"homepage.icon":         *(Service + ".png") | string
			"homepage.href":         *("https://" + _domain) | string
			"homepage.description"?: string
		}

		if _pangolin != _|_ if _pangolin == true {
			"pangolin.public-resources.\(Service).name":              *Service | string
			"pangolin.public-resources.\(Service).full-domain":       *_domain | string
			"pangolin.public-resources.\(Service).mode":              *"http" | string
			"pangolin.public-resources.\(Service).targets[0].method": *"http" | string
			"pangolin.public-resources.\(Service).targets[0].port"?:  int
			"pangolin.public-resources.\(Service).policy":            #PangolinPolicy
		}

		if _traefik != _|_ if _traefik == true {
			"traefik.enable":                                             true
			"traefik.http.routers.\(Service).rule":                       *"Host(`\(Service).henn.dev`)" | string
			"traefik.http.routers.\(Service).entrypoints":                *"websecure" | string
			"traefik.http.routers.\(Service).middlewares":                *"hdrs@file" | string
			"traefik.http.routers.\(Service).tls.certresolver":           *"cf" | string
			"traefik.http.services.\(Service).loadbalancer.server.port"?: int
		}
	}
}

#NVGpu: resources: reservations: devices: [{
	driver: "nvidia"
	count:  "all"
	capabilities: ["gpu"]
}]
