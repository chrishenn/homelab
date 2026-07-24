package rack4

services: comfy: {
	image:      "yanwk/comfyui-boot:cu130-slim"
	stdin_open: true
	tty:        true
	runtime:    "nvidia"
	deploy:     #NVGpu
	environment: CLI_ARGS: "--fast --listen 0.0.0.0"
	volumes: [
		"$DATA/comfy/root:/root",
		"$DATA/comfy/custom_nodes:/root/ComfyUI/custom_nodes",
		"$DATA/comfy/models:/root/ComfyUI/models",
		"$DATA/comfy/hf-hub:/root/.cache/huggingface/hub",
		"$DATA/comfy/torch-hub:/root/.cache/torch/hub",
		"$DATA/comfy/input:/root/ComfyUI/input",
		"$DATA/comfy/output:/root/ComfyUI/output",
		"$DATA/comfy/workflows:/root/ComfyUI/user/default/workflows",
	]
	healthcheck: test: "curl -ILfSs http://localhost:8188"
	expose: ["8188"]
	_pangolin: true
	labels: {
		"homepage.group":                         "AI"
		"homepage.icon":                          "comfy-ui.png"
		"homepage.description":                   "Image Gen"
		"pangolin.public-resources.comfy.policy": "chris"
	}
}
