package rack4

services: ollama: _gpu & {
	image: "ollama/ollama:latest"
	environment: {
		OLLAMA_CONTEXT_LENGTH:  32000
		OLLAMA_FLASH_ATTENTION: 1
	}
	volumes: ["$DATA/ollama:/root/.ollama"]
	networks: ["ollama"]
	expose: ["11434"]
}
networks: ollama: {}
