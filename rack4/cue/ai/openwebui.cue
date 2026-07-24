package rack4

services: openwebui: {
	image: "ghcr.io/open-webui/open-webui:latest"
	volumes: ["$DATA/ollama/webui:/app/backend/data"]
	environment: {
		ENABLE_PERSISTENT_CONFIG:       false
		WEBUI_URL:                      "https://ollama.chenn.dev"
		WEBUI_AUTH:                     true
		WEBUI_NAME:                     "Chicken AI"
		OLLAMA_BASE_URLS:               "http://ollama:11434"
		AUDIO_STT_ENGINE:               "openai"
		AUDIO_STT_OPENAI_API_BASE_URL:  "http://speach:8000/v1"
		AUDIO_STT_OPENAI_API_KEY:       "super_secure_key"
		AUDIO_STT_MODEL:                "Systran/faster-whisper-large-v3"
		AUDIO_TTS_ENGINE:               "openai"
		AUDIO_TTS_OPENAI_API_BASE_URL:  "http://speach:8000/v1"
		AUDIO_TTS_OPENAI_API_KEY:       "super_secure_key"
		AUDIO_TTS_MODEL:                "speaches-ai/Kokoro-82M-v1.0-ONNX"
		AUDIO_TTS_VOICE:                "bf_isabella"
		OPENID_PROVIDER_URL:            "https://pocketid.chenn.dev/.well-known/openid-configuration"
		OAUTH_CLIENT_ID:                "$OLLAMA_OIDC_CLIENT"
		OAUTH_CLIENT_SECRET:            "$OLLAMA_OIDC_SECRET"
		OAUTH_PROVIDER_NAME:            "PocketID"
		OAUTH_SCOPES:                   "openid email profile groups"
		OAUTH_CODE_CHALLENGE_METHOD:    "S256"
		OAUTH_MERGE_ACCOUNTS_BY_EMAIL:  true
		ENABLE_OAUTH_ID_TOKEN_COOKIE:   false
		ENABLE_OAUTH_PERSISTENT_CONFIG: false
		ENABLE_OAUTH_SIGNUP:            true
		ENABLE_LOGIN_FORM:              true
		ENABLE_PASSWORD_AUTH:           true
	}
	healthcheck: test: "curl -ILfSs http://localhost:8080"
	networks: ["newt", "ollama"]
	expose: ["8080"]
	_pangolin: true
	_domain: "ollama.chenn.dev"
	labels: {
		"homepage.group":                                  "AI"
		"homepage.description":                            "AI Chat"
	}
}
