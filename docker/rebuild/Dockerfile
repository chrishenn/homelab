FROM docker:cli

RUN set -x;  \
    echo https://downloads.1password.com/linux/alpinelinux/stable/ >> /etc/apk/repositories; \
    wget https://downloads.1password.com/linux/keys/alpinelinux/support@1password.com-61ddfc31.rsa.pub -P /etc/apk/keys; \
    apk add --update --no-cache 1password-cli supercronic shadow tzdata libc6-compat; \
    rm -rf /tmp/* ; \
    rm -rf /var/cache/apk/*

COPY entrypoint.sh .

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
CMD ["/usr/bin/supercronic", "-debug", "crontab"]
