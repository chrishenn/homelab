@experiment(try)

package apps

// If one homepage label is present, then they all should be present or added via a default/constraint
// I suspect this is possible with a field comprehension https://cuelang.org/docs/tour/expressions/fieldcomp/

#Homepage_group: "Arr" | "AI"

//services: [Service=_]: labels: {
//	"homepage.name": *Service | string
//	"homepage.group": #Homepage_group
//	"homepage.icon": *(Service + ".png") | string
//	"homepage.href": *("https://" + Service + ".chenn.dev") | string
//	"homepage.description"?: string
//}

#Homepage_labels: {
	name="homepage.name": string
	"homepage.group": #Homepage_group
	"homepage.icon": *(name + ".png") | string
	"homepage.href": *("https://" + name + ".chenn.dev") | string
	"homepage.description": string
}

#Other_labels: {
	"pangolin.public-resources.sonarr.name":              string
}

services: {
	radarr: {
		profiles: ["arr"]
		image:          "lscr.io/linuxserver/radarr:latest"
		container_name: "radarr"
		restart:        "unless-stopped"
		environment: {
			PUID:                 "${PUID}"
			PGID:                 "${PGID}"
			TZ:                   "${TZ}"
			RADARR__AUTH__METHOD: "External"
		}
		volumes: [
			"$DATA/radarr:/config",
			"$DATA/sab/downloads:/sab/downloads",
			"$DATA/qbit/downloads:/qbit/downloads",
			"$MEDIA:/media_library",
		]
		networks: ["arr", "newt"]
		labels: (#Homepage_labels & {
			"homepage.name": "radarr"
			"homepage.group":                                     "Arr"
			"homepage.description":                               "Movie Manager"
		})
	}

//	sonarr: {
//		profiles: ["arr"]
//		image:          "lscr.io/linuxserver/sonarr:latest"
//		container_name: "sonarr"
//		restart:        "unless-stopped"
//		environment: {
//			PUID:                 "${PUID}"
//			PGID:                 "${PGID}"
//			TZ:                   "${TZ}"
//			SONARR__AUTH__METHOD: "External"
//		}
//		volumes: [
//			"$DATA/sonarr:/config",
//			"$DATA/sab/downloads:/sab/downloads",
//			"$DATA/qbit/downloads:/qbit/downloads",
//			"$MEDIA:/media_library",
//		]
//		networks: ["arr", "newt"]
//		labels: {
//			"homepage.group":                                     "Arr"
//			"homepage.name":                                      "Sonarr"
//			"homepage.icon":                                      "sonarr.png"
//			"homepage.href":                                      "https://sonarr.chenn.dev"
//			"homepage.description":                               "TV Manager"
//			"pangolin.public-resources.sonarr.name":              "sonarr"
//			"pangolin.public-resources.sonarr.full-domain":       "sonarr.chenn.dev"
//			"pangolin.public-resources.sonarr.mode":              "http"
//			"pangolin.public-resources.sonarr.targets[0].method": "http"
//			"pangolin.public-resources.sonarr.targets[0].port":   8989
//			"pangolin.public-resources.sonarr.policy":            "arr"
//		}
//	}

}
networks: arr: null
