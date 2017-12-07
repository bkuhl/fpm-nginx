FROM php:7.2.0-fpm-alpine

WORKDIR /var/www/html

COPY install_composer.php /var/www/html/install_composer.php

ENV S6_OVERLAY_VERSION=v1.21.2.1

# ------------------------ add nginx ------------------------
# Taken from official nginx container Dockerfile

RUN apk add --update --no-cache nginx \

# ------------------------ add s6 ------------------------
    && apk add --no-cache curl \
    && curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz \
    | tar xfz - -C / \
    && apk del curl

# ------------------------ Common PHP Dependencies ------------------------
RUN apk add \

        # needed for gd
        libpng-dev libjpeg-turbo-dev \

    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    
    # Installing composer
    && php /var/www/html/install_composer.php \

    # Installing common Laravel dependencies
    && docker-php-ext-install mbstring pdo_mysql gd \
    
    	# Adding opcache
    	opcache \

    # For parallel composer dependency installs
    && composer global require hirak/prestissimo \

    && mkdir -p /home/www-data/.composer/cache \

    && chown -R www-data:www-data /home/www-data/ /var/www/html \
    
    && rm /var/www/html/install_composer.php

# ------------------------ start fpm/nginx ------------------------

COPY services.d /etc/services.d
COPY nginx.conf /etc/nginx/nginx.conf

# Add default virtualhost
# Still needs work
#ADD ./default.conf /etc/nginx/conf.d/default.conf

# Adding the opcache configuration into the wrong directory intentionally.
# This is enabled at runtime
ADD opcache.ini /usr/local/etc/php/opcache_disabled.ini

EXPOSE 80

ENTRYPOINT ["/init"]
CMD []
