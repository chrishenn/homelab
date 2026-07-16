package rack4

services: speach: _gpu & {
	image: "ghcr.io/speaches-ai/speaches:latest-cuda"
	volumes: ["$DATA/speach:/home/ubuntu/.cache/huggingface/hub"]
	healthcheck: test: "curl -f http://speach:8000/health"
	expose: ["8000"]
	networks: ["traefik"]
	labels: {
		"homepage.group":       "AI"
		"homepage.icon":        "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/speaches.svg"
		"homepage.description": "Text To Speech"
	}
}
