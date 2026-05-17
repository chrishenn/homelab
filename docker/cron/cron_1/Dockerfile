FROM alpine:latest

# mount your crontab file at /home/app/crontab

ARG PUID=1000
ARG PGID=1000

RUN set -x; \
    apk add --no-cache --update rsync sudo openssh-client ca-certificates supercronic shadow tzdata \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/*

RUN adduser -D app -u $PUID -g $PGID \
        && echo "app ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/app \
        && chmod 0440 /etc/sudoers.d/app

USER app
CMD ["/usr/bin/supercronic", "-debug", "/home/app/crontab"]
