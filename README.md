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

## Adding Processes

This container uses [S6 Overlay](https://github.com/just-containers/s6-overlay) as it's process monitoring solution.  Add a new directory to `services.d` with a `run` file in it where `run` in a shell script that kicks off the process.  The rest is taken care of for you.
