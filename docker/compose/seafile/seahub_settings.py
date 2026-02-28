# collabora
ENABLE_OFFICE_WEB_APP = True
OFFICE_SERVER_TYPE = "CollaboraOffice"
OFFICE_WEB_APP_BASE_URL = "https://collabora.chenn.dev/hosting/discovery"
WOPI_ACCESS_TOKEN_EXPIRATION = 30 * 60
OFFICE_WEB_APP_FILE_EXTENSION = (
    "odp",
    "ods",
    "odt",
    "xls",
    "xlsb",
    "xlsm",
    "xlsx",
    "ppsx",
    "ppt",
    "pptm",
    "pptx",
    "doc",
    "docm",
    "docx",
)
ENABLE_OFFICE_WEB_APP_EDIT = True
OFFICE_WEB_APP_EDIT_FILE_EXTENSION = (
    "odp",
    "ods",
    "odt",
    "xls",
    "xlsb",
    "xlsm",
    "xlsx",
    "ppsx",
    "ppt",
    "pptm",
    "pptx",
    "doc",
    "docm",
    "docx",
)


# oidc
import os

ENABLE_OAUTH = True
OAUTH_CREATE_UNKNOWN_USER = True
OAUTH_ACTIVATE_USER_AFTER_CREATION = True
OAUTH_ENABLE_INSECURE_TRANSPORT = False

OAUTH_CLIENT_ID = os.environ["OIDC_CLIENT"]
OAUTH_CLIENT_SECRET = os.environ["OIDC_SECRET"]
OAUTH_REDIRECT_URL = os.environ["OIDC_REDIRECT"]
OAUTH_PROVIDER_DOMAIN = os.environ["OIDC_DOMAIN"]
OAUTH_PROVIDER = os.environ["OIDC_PROVIDER"]
OAUTH_AUTHORIZATION_URL = os.environ["OIDC_AUTH_URL"]
OAUTH_TOKEN_URL = os.environ["OIDC_TOKEN_URL"]
OAUTH_USER_INFO_URL = os.environ["OIDC_USER_URL"]
OAUTH_SCOPE = ["openid", "email", "profile"]
OAUTH_ATTRIBUTE_MAP = {
    "sub": (True, "uid"),
    "email": (True, "email"),
    "name": (False, "name"),
}

# smtp
EMAIL_USE_TLS = True
EMAIL_HOST = os.environ["SMTP_HOST"]
SERVER_EMAIL = EMAIL_HOST_USER = os.environ["SMTP_USER"]
EMAIL_HOST_PASSWORD = os.environ["SMTP_PASS"]
EMAIL_PORT = 465
DEFAULT_FROM_EMAIL = os.environ["SMTP_FROM"]
