# immich

docker compose

```bash
cd ~/Documents
mkdir ./immich
cd ./immich

# in the admin page under "video transcoding settings" change the hardware setting, and enable hardware decoding

# use these files for reference. They get merged into the compose file I'm using
wget -O compose.yml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env
wget -O hwaccel.transcoding.yml https://github.com/immich-app/immich/releases/latest/download/hwaccel.transcoding.yml
wget -O hwaccel.ml.yml https://github.com/immich-app/immich/releases/latest/download/hwaccel.ml.yml
```

# refs

https://github.com/joshua-holmes/google-photos-metadata-fix
https://github.com/nveloso/google-takeout-photos-recover
https://github.com/TheLastGimbus/GooglePhotosTakeoutHelper
https://github.com/Greegko/google-metadata-matcher
https://github.com/anderbggo/GooglePhotosMatcher
https://github.com/naftalibeder/porte
