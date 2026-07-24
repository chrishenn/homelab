package rack4

#HomepageGroup:  "Arr" | "AI"
#PangolinPolicy: *"member" | "arr"

services: [Service=_]: {
	profiles: [string]
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
			"homepage.group"!:       #HomepageGroup
			"homepage.name":         *Service | string
			"homepage.icon":         *(Service + ".png") | string
			"homepage.href":         *("https://" + Service + ".chenn.dev") | string
			"homepage.description"?: string
		}

		_pangolin?: bool
		if _pangolin != _|_ if _pangolin == true {
			"pangolin.public-resources.\(Service).name":              *Service | string
			"pangolin.public-resources.\(Service).full-domain":       *(Service + ".chenn.dev") | string
			"pangolin.public-resources.\(Service).mode":              *"http" | string
			"pangolin.public-resources.\(Service).targets[0].method": *"http" | string
			"pangolin.public-resources.\(Service).targets[0].port"?:  int
			"pangolin.public-resources.\(Service).policy":            #PangolinPolicy
		}
	}
}
