package rack4

services: ollama: {
	profiles: ["ollama"]
	image:          "ollama/ollama:latest"
	runtime:        "nvidia"
	deploy: resources: reservations: devices: [{
		driver: "nvidia"
		count: "all"
		capabilities: ["gpu"]
	}]
	environment: {
		OLLAMA_CONTEXT_LENGTH:  32000
		OLLAMA_FLASH_ATTENTION: 1
	}
	volumes: ["$DATA/ollama:/root/.ollama"]
	networks: ["ollama"]
}
networks: ollama: null
