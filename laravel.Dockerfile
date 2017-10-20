FROM bkuhl/fpm-nginx:latest

RUN
    apk add --update --no-cache yarn \

    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
