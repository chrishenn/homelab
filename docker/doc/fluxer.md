# fluxer

default s3 ships seaweedfs - rustfs seems more stable

```yaml
x-fluxer_common_once: &fluxer_common_once
x-fluxer_common: &fluxer_common

fluxer-s3:
    image: chrislusf/seaweedfs:latest
    container_name: fluxer-s3
    <<: *fluxer_common
    command: server -s3 -filer -dir=/data -ip=0.0.0.0 -volume.max=100
    volumes:
      - $DATA/fluxer/s3:/data

# dc run --rm -it --entrypoint /bin/ash fluxer-s3-init
# echo "s3.bucket.list" | timeout 10 weed shell -master=fluxer-s3:9333
fluxer-s3-init:
    image: chrislusf/seaweedfs:latest
    container_name: fluxer-s3-init
    <<: *fluxer_common_once
    entrypoint:
      - /bin/sh
      - -c
      - >
          buckets="fluxer fluxer-uploads fluxer-downloads fluxer-reports fluxer-harvests";
          missing="$$buckets";
          for attempt in $$(seq 1 60); do
            if ! nc -z fluxer-s3 9333 2>/dev/null; then
              sleep 2;
              continue;
            fi;
            listed=$$(echo "s3.bucket.list" | timeout 10 weed shell -master=fluxer-s3:9333 2>&1);
            missing="";
            for b in $$buckets; do
              echo "$$listed" | grep -q "^[[:space:]]*$$b[[:space:]]" || missing="$${missing:+$$missing }$$b";
            done;
            if [ -z "$$missing" ]; then
              echo "buckets ready";
              exit 0;
            fi;
            for b in $$missing; do
              echo "s3.bucket.create -name $$b" | timeout 10 weed shell -master=fluxer-s3:9333 >/dev/null 2>&1;
            done;
            sleep 2;
          done;
          echo "fluxer-s3-init could not verify buckets: $$missing" >&2;
          exit 1;
```
