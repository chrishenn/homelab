package rack4

services: dockscope: {
	// versions after v0.5.0 are borked
	image: "ghcr.io/manuelr-t/dockscope:v0.5.0"
	volumes: ["/var/run/docker.sock:/var/run/docker.sock"]
	networks: ["newt", "traefik"]
	expose: ["4681"]
	labels: {
		"homepage.group":       "Infra"
		"homepage.icon":        "docker-engine.png"
		"homepage.description": "3D Docker Visualizer"
	}
}
