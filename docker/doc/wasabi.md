# wasabi

rc: rustfs tool to list s3 filesystems:

```bash
mise use github:rustfs/cli

nano ~/.config/rc/config.toml
# schema_version = 1
#
# [defaults]
# output = "human"
# color = "auto"
# progress = true
#
# [[aliases]]
# name = "wasabi"
# endpoint = "https://s3.us-east-1.wasabisys.com"
# access_key = ""
# secret_key = ""
# region = "us-east-1"

rc ls wasabi/bucket0.henn.dev
rc du wasabi/bucket0.henn.dev --fallback
```

minio and mc are no longer publishing images; use rc instead

```bash
nano ~/.mc/config.json
# "wasabi": {
#    "url": "https://s3.us-east-1.wasabisys.com",
#    "accessKey": "",
#    "secretKey": "",
#    "api": "S3v4",
#    "path": "dns"
# }
mc ls wasabi/bucket0.henn.dev
mc du wasabi/bucket0.henn.dev
```
