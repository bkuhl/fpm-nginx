FROM php:8.3.0-fpm-alpine3.17

WORKDIR /var/www/html

COPY install_composer.sh /var/www/html/install_composer.sh

RUN apk add nginx s6-overlay

# ------------------------ Common PHP Dependencies ------------------------
RUN apk update && apk add \
        # see https://github.com/docker-library/php/issues/880
        oniguruma-dev \
        # needed for gd
        libpng-dev libjpeg-turbo-dev \
		# needed for xdebug
		$PHPIZE_DEPS \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    # Installing composer
    && sh /var/www/html/install_composer.sh \
    # Installing common Laravel dependencies
    && docker-php-ext-install mbstring pdo_mysql gd \
    	opcache \
    && mkdir -p /home/www-data/.composer/cache \
    && chown -R www-data:www-data /home/www-data/ /var/www/html \
    && rm /var/www/html/install_composer.sh


# ------------------------ xdebug ------------------------
ARG XDEBUG_ENABLE=false
ARG REMOTE_XDEBUG_HOST=0.0.0.0
ARG REMOTE_XDEBUG_PORT=9999
RUN if [ "$XDEBUG_ENABLE" = "true" ]; then \
	pecl install xdebug-3.0.0; \
    docker-php-ext-enable xdebug; \
    echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    echo "xdebug.remote_host=${REMOTE_XDEBUG_HOST}" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    echo "xdebug.remote_port=${REMOTE_XDEBUG_PORT}" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    echo "xdebug.remote_connect_back=On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    echo "xdebug.idekey=x_debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
	mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.disabled; \
	fi

# ------------------------ start fpm/nginx ------------------------

COPY services.d /etc/services.d
COPY nginx.conf /etc/nginx/nginx.conf

# Adding the opcache configuration into the wrong directory intentionally.
# This is enabled at runtime
ADD opcache.ini /usr/local/etc/php/opcache_disabled.ini

ADD healthcheck.ini /usr/local/etc/php/healthcheck.ini

RUN rm -rf /var/cache/apk/* && \
        rm -rf /tmp/*

EXPOSE 80

ENTRYPOINT ["/init"]
CMD []
