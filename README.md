# FPM/Nginx - [Dockerhub Repo](https://hub.docker.com/r/bkuhl/fpm-nginx/)

This container is intended to run Laravel applications and thus comes with a few items to assist:

 * [Composer](https://getcomposer.org)
 * PHP Extensions
   * [mbstring](http://php.net/manual/en/book.mbstring.php)
   * [pdo_mysql](http://php.net/manual/en/ref.pdo-mysql.php)
   * [gd](http://php.net/manual/en/book.image.php)
   * [opcache](http://php.net/manual/en/book.opcache.php) - Automatically enabled when `APP_ENV=production`
   * [xdebug](https://xdebug.org) - Only enabled when `XDEBUG_ENABLE=true`.  Only installed when `XDEBUG_ENABLE=true` when building the container
 * Adding a default virtual host serving apps from `/var/www/html/public`
   
For Laravel applications, see [bkuhl/laravel-fpm-nginx](https://github.com/bkuhl/laravel-fpm-nginx).

For a container to run cron and other CLI tasks, check out [bkuhl/php](https://github.com/bkuhl/php).

**Why 2 processes in 1 container?**

 1. DNS issues - Both the fpm/nginx containers need to be redeployed when your application is updated.  Nginx maintains an internal DNS cache, so while Docker may ensure zero downtime for fpm containers, nginx's internal workings can still create problems.  The only way to solve this (that I've found) is to restart the nginx process.  Having them on the same container eliminates the problem.
 2. Laravel Mix - The front/backend of applications are kind of coupled when using something like Laravel Mix.  The index of assets it creates need to be on both containers and running these separately is possible, but redundant.  

## Executing commands as www-data user

By default container uses `root` user, that is [a requirement for s6 overlay tool](https://github.com/glerchundi/s6-overlay-builder/blob/63ef8f6d1f28797b0027b68f877ce091fafb56b7/README.md#notes). So all of your commands will be executed as `root`

If you need to run commands as php-fpm user (`www-data`), you need to use `runuser` command, example
```
runuser -u www-data composer install
```

## Adding Processes

This container uses [S6 Overlay](https://github.com/just-containers/s6-overlay) as it's process monitoring solution.  Add a new directory to `services.d` with a `run` file in it where `run` in a shell script that kicks off the process.  The rest is taken care of for you.

## Example Dockerfile

```
FROM bkuhl/fpm-nginx:latest

WORKDIR /var/www/html

# Copy the application files to the container
ADD --chown=www-data:www-data  . /var/www/html

USER www-data

RUN composer install  --no-interaction --optimize-autoloader --no-dev --no-cache --prefer-dist
```

