FROM alpine:latest

ARG USER=app
ENV APPDIR=/home/app
ARG PUID=1000
ARG PGID=1000

# these run as root
RUN set -x; \
    apk add --no-cache --update rsync sudo openssh-client ca-certificates supercronic shadow tzdata \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/*

RUN adduser -D app -u $PUID -g $PGID \
        && echo "app ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/app \
        && chmod 0440 /etc/sudoers.d/app

# these run as user
USER $USER
WORKDIR $APPDIR

COPY entrypoint.sh .
RUN sudo chown $PUID:$PGID entrypoint.sh && sudo sudo chmod a+x entrypoint.sh

# entrypoint.sh renders the crontab file on container start
ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
CMD ["/usr/bin/supercronic", "-debug", "crontab"]
