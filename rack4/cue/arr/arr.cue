package rack4

_ArrCmn: {
	_group: "arr"
	environment: {
		PUID: "${PUID}"
		PGID: "${PGID}"
		TZ:   "${TZ}"
	}
}
services: {
	radarr: _ArrCmn & {
		image: "lscr.io/linuxserver/radarr:latest"
		environment: {
			RADARR__AUTH__METHOD: "External"
		}
		volumes: [
			"$DATA/radarr:/config",
			"$DATA/sab/downloads:/sab/downloads",
			"$DATA/qbit/downloads:/qbit/downloads",
			"$MEDIA:/media_library",
		]
		networks: ["arr", "newt"]
		expose: ["7878"]

		_homepage: {
			description: "Movie Manager"
		}
		_pangolin: {
			policy: "arr"
		}

	}
//	sonarr: _ArrCmn & {
//		image: "lscr.io/linuxserver/sonarr:latest"
//		environment: {
//			SONARR__AUTH__METHOD: "External"
//		}
//		volumes: [
//			"$DATA/sonarr:/config",
//			"$DATA/sab/downloads:/sab/downloads",
//			"$DATA/qbit/downloads:/qbit/downloads",
//			"$MEDIA:/media_library",
//		]
//		networks: ["arr", "newt"]
//		expose: ["8989"]
//		labels: {
//			"homepage.group":                          "Arr"
//			"pangolin.public-resources.sonarr.policy": "arr"
//		}
//	}
}
networks: arr: {}
