package rack4

services: comfy: _gpu & {
	image: "yanwk/comfyui-boot:cu130-slim"
	environment: CLI_ARGS: "--fast --listen 0.0.0.0"
	volumes: [
		"\(comfy._store)/root:/root",
		"\(comfy._store)/custom_nodes:/root/ComfyUI/custom_nodes",
		"\(comfy._store)/models:/root/ComfyUI/models",
		"\(comfy._store)/hf-hub:/root/.cache/huggingface/hub",
		"\(comfy._store)/torch-hub:/root/.cache/torch/hub",
		"\(comfy._store)/input:/root/ComfyUI/input",
		"\(comfy._store)/output:/root/ComfyUI/output",
		"\(comfy._store)/workflows:/root/ComfyUI/user/default/workflows",
	]
	healthcheck: test: "curl -ILfSs http://localhost:8188"
	expose: ["8188"]
	networks: ["newt"]
	labels: {
		"homepage.group":                         "AI"
		"homepage.icon":                          "comfy-ui.png"
		"homepage.description":                   "Image Gen"
		"pangolin.public-resources.comfy.policy": "chris"
	}
}
