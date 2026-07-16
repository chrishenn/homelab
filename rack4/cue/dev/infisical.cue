package rack4

#InfisicalEnv: {
	SITE_URL:             "https://infisical.chenn.dev"
	ENCRYPTION_KEY:       "${INFISICAL_ENCRYPTION_KEY}"
	AUTH_SECRET:          "${INFISICAL_AUTH_SECRET}"
	NODE_ENV:             "production"
	DB_CONNECTION_URI:    "postgres://infisical:infisical@infisical_db:5432/infisical"
	POSTGRES_PASSWORD:    "infisical"
	POSTGRES_USER:        "infisical"
	POSTGRES_DB:          "infisical"
	REDIS_URL:            "redis://infisical_redis:6379"
	ALLOW_EMPTY_PASSWORD: "yes"
	SMTP_HOST:            "${SMTP_HOST}"
	SMTP_PORT:            465
	SMTP_FROM_ADDRESS:    "${SMTP_USER}"
	SMTP_FROM_NAME:       "chris"
	SMTP_USERNAME:        "${SMTP_USER}"
	SMTP_PASSWORD:        "${SMTP_TOKEN}"
}
_InfisicalCommon: {
	_group: "infisical"
	profiles: [_group]
	environment: #InfisicalEnv
	networks: ["infisical", ...string]
}
services: {
	infisical: _InfisicalCommon & {
		image: "infisical/infisical:latest"
		networks: ["infisical", "newt"]
		expose: ["8080"]
		labels: {
			"homepage.group":       "Development Tools"
			"homepage.description": "Dev Secrets"
		}
	}
	infisical_db:    _InfisicalCommon
	infisical_redis: _InfisicalCommon
}
networks: infisical: {}
