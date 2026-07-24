package rack4

services: speach: {
	profiles: ["speach"]
	image:  "ghcr.io/speaches-ai/speaches:latest-cuda"
	deploy: #NVGpu
	healthcheck: test: "curl -f http://speach:8000/health"
	volumes: ["$DATA/speach:/home/ubuntu/.cache/huggingface/hub"]
	expose: ["8000"]
	networks: ["traefik"]
	_traefik:               true
	_domain: "speach.henn.dev"
	labels: {
		"homepage.group":       "AI"
		"homepage.icon":        "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/speaches.svg"
		"homepage.description": "AI TTS/STT"
	}
}
