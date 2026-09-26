# fluxer

https://docs.fluxer.app/

My god, they went sicko mode on the documentation. Plus, actually usuable log messages in each container's process?
Absolutely top-tier work.

sso callback urls. second one is for the android app

- https://fluxer.chenn.dev/auth/sso/callback
- fluxer://auth/sso/callback

## todo

- [x] passkey login failed on android app
- [ ] enable fcm firebase push
- [ ] fix performance issues (video playback to android. May be unfixable due to pangolin tunnel)

---

## s3

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

notes

setting this, or using the google play app, breaks passkeys as of 09/26/26
FLUXER_PASSKEY_ADDITIONAL_ALLOWED_ORIGINS: https://fluxer.chenn.dev

---

I found out that these video playback issues affect all messaging apps on chrome/linux on my fedora aurora setup. Zen
browser works fine.

video playback problems. Smaller videos will generally playback, but there are buffering/chunking issues that are
  made evident with larger vids
it looks like either the web client or fluxer media proxy is timing out at 30s
low-bitrate+shorter videos playback with no problems
low-bitrate+longer videos take forever to buffer and begin playback initially due to errored-out chunks
high-bitrate+shorter videos start playback quicker but don't buffer quickly enough, so only a few seconds play at a time
https://github.com/fluxerapp/fluxer/issues/1366

firefox: play failed: the media resource ... was not suitable. NS_ERROR_NET_PARTIAL_TRANSFER
firefox: media resource https://fluxer.chenn.dev/media/attachmetns/id/id/name.mkv could not be dcoded, NS_ERROR_DOM_MEDIA_METADATA_ERR
fluxer_media: status 206, no errors
fluxer_api  | {
 "type":"Error", "message": "Command failed: ffmpeg ..."
            "Unable to find a suitable output format for /tmp/id"
            "/tmp/id: Invalid argument"

I can curl about the same 100 MB
Hey, uh ... guys? Why are my uploaded files available on a public url without a login session?
curl https://fluxer.chenn.dev/media/attachments/1539129081084248067/1539131161991708672/file.mp4 -o dl.mp4
 % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current Dload  Upload  Total   Spent   Left   Speed
31 380.7M  31 118.8M   0      0  3.56M      0   01:46   00:33   01:13  3.08M
curl: (92) HTTP/2 stream 1 reset by server (error 0x2 INTERNAL_ERROR)

I'm seeing very close to a 30-second timeout in a couple places here
fluxer-s3:
"level": "WARN",
"message": "GetObject streaming body dropped before expected length",
"event": "get_object_stream_body",
"component": "app",
"subsystem": "object",
"bucket": "fluxer",
"object": "attachments/id1/id2/file.mp4",
"range": "bytes 17301504-399284032/399284033",
"expected": 381982529,
"emitted": 78643200,
"elapsed_ms": "30000",
"state": "dropped_incomplete",
