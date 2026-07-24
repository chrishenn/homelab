package rack4

services: speach: {
	profiles: ["speach"]
	image:          "ghcr.io/speaches-ai/speaches:latest-cuda"
	container_name: "speach"
	restart:        "unless-stopped"
	deploy: resources: reservations: devices: [{
		driver: "nvidia"
		count:  "all"
		capabilities: ["gpu"]
	}]
	healthcheck: test: ["CMD", "curl", "--fail", "http://speach:8000/health"]
	volumes: ["$DATA/speach:/home/ubuntu/.cache/huggingface/hub"]
	networks: ["traefik"]
	labels: {
		"homepage.group":                                        "AI"
		"homepage.icon":                                         "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/speaches.svg"
		"homepage.description":                                  "AI TTS/STT"
		"traefik.enable":                                        true
		"traefik.http.routers.speach.rule":                      "Host(`speach.henn.dev`)"
		"traefik.http.routers.speach.entrypoints":               "websecure"
		"traefik.http.routers.speach.middlewares":               "hdrs@file"
		"traefik.http.routers.speach.tls.certresolver":          "cf"
		"traefik.http.services.speach.loadbalancer.server.port": 8000
	}
}
