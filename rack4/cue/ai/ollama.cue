package rack4

services: ollama: {
	image:   "ollama/ollama:latest"
	runtime: "nvidia"
	deploy:  #NVGpu
	environment: {
		OLLAMA_CONTEXT_LENGTH:  32000
		OLLAMA_FLASH_ATTENTION: 1
	}
	volumes: ["$DATA/ollama:/root/.ollama"]
	networks: ["ollama"]
}
networks: ollama: null
