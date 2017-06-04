# FPM/Nginx

[![Docker Build](https://img.shields.io/docker/build/bkuhl/fpm-nginx.svg)](https://hub.docker.com/r/bkuhl/fpm-nginx)
[![Docker Pulls](https://img.shields.io/docker/pulls/bkuhl/fpm-nginx.svg)](https://hub.docker.com/r/bkuhl/fpm-nginx)
![Automated](https://img.shields.io/docker/automated/bkuhl/fpm-nginx.svg)

This container is intended to run Laravel applications and thus comes with a few items to assist:

 * [Composer](https://getcomposer.org) (with [hirak/prestissimo](https://github.com/hirak/prestissimo) for parallel dependency installation)
 * PHP Extensions
   * [mbstring](http://php.net/manual/en/book.mbstring.php)
   * [pdo_mysql](http://php.net/manual/en/ref.pdo-mysql.php)
   * [gd](http://php.net/manual/en/book.image.php)
   * [opcache](http://php.net/manual/en/book.opcache.php) - Automatically enabled when `APP_ENV=production`
   
   
The `laravel-*` tag contains:
 * Laravel Mix support via [Node](https://nodejs.org), [Npm](https://www.npmjs.com) and [Yarn](https://yarnpkg.com)  

For a container to run cron, migrations or queue workers for Laravel applications, check out [bkuhl/php](https://github.com/bkuhl/php)

**Why 2 processes in 1 container?**

 1. DNS issues - Both the fpm/nginx containers need to be redeployed when your application is updated.  Nginx maintains an internal DNS cache, so while Docker may ensure zero downtime for fpm containers, nginx's internal workings can still create problems.  The only way to solve this (that I've found) is to restart the nginx process.  Having them on the same container eliminates the problem.
 2. Laravel Mix - The front/backend of applications are kind of coupled when using something like Laravel Mix.  The index of assets it creates need to be on both containers and running these separately is possible, but redundant.  

## Adding Processes

This container uses [S6 Overlay](https://github.com/just-containers/s6-overlay) as it's process monitoring solution.  Add a new directory to `services.d` with a `run` file in it where `run` in a shell script that kicks off the process.  The rest is taken care of for you.

## Example Dockerfile

```
FROM bkuhl/fpm-nginx:fpm-7_nginx-1

WORKDIR /var/www/html

# Copy the application files to the container
ADD . /var/www/html

# Can be removed once https://github.com/moby/moby/issues/6119 is released
RUN chown -R www-data:www-data /var/www/html /home/www-data

# Run composer as www-data
# Can be moved before application files are added to the container once
# the issue mentioned above is fixed and released
USER www-data

RUN \

    # production-ready dependencies
    composer install  --no-interaction --optimize-autoloader --no-dev --prefer-dist \

    # keep the container light weight
    && rm -rf /home/www-data/.composer/cache

# add vhost config
ADD ./infrastructure/web/default.conf /etc/nginx/conf.d/default.conf

USER root
```
