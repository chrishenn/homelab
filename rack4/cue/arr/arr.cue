package rack4

services: {
	radarr: {
		profiles: ["arr"]
		image: "lscr.io/linuxserver/radarr:latest"
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
		expose: ["8989"]
		labels: {
			"homepage.group": "Arr"

			_pangolin:                                 true
			"pangolin.public-resources.radarr.policy": "arr"
		}
	}

	sonarr: {
		profiles: ["arr"]
		image: "lscr.io/linuxserver/sonarr:latest"
		environment: {
			PUID:                 "${PUID}"
			PGID:                 "${PGID}"
			TZ:                   "${TZ}"
			SONARR__AUTH__METHOD: "External"
		}
		volumes: [
			"$DATA/sonarr:/config",
			"$DATA/sab/downloads:/sab/downloads",
			"$DATA/qbit/downloads:/qbit/downloads",
			"$MEDIA:/media_library",
		]
		networks: ["arr", "newt"]
		expose: ["8989"]
		labels: {
			"homepage.group": "Arr"

			_pangolin:                                 true
			"pangolin.public-resources.sonarr.policy": "arr"
		}
	}

}

networks: arr: null
