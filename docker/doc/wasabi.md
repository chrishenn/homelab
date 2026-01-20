# wasabi

mc minio tool to list s3 filesystems:

```bash
brew install minio/stable/mc
nano ~/.mc/config.json

# "wasabi0": {
#    "url": "https://s3.us-east-1.wasabisys.com",
#    "accessKey": "",
#    "secretKey": "",
#    "api": "S3v4",
#    "path": "dns"
# }
mc ls wasabi0/bucket0.henn.dev
mc du wasabi0/bucket0.henn.dev
```
