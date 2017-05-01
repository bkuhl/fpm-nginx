# FPM/Nginx

[![Docker Build](https://img.shields.io/docker/build/bkuhl/fpm-nginx.svg)](https://hub.docker.com/r/bkuhl/fpm-nginx)
[![Docker Pulls](https://img.shields.io/docker/pulls/bkuhl/fpm-nginx.svg)](https://hub.docker.com/r/bkuhl/fpm-nginx)
![Automated](https://img.shields.io/docker/automated/bkuhl/fpm-nginx.svg)

Sometimes it's best to combine provide a single container for service/app distribution.  These containers include both PHP-FPM and Nginx in a single container.  Other processes can easily be added as well.

## Adding Processes

This container uses [S6 Overlay](https://github.com/just-containers/s6-overlay) as it's process monitoring solution.  Add a new directory to `services.d` with a `run` file in it where `run` in a shell script that kicks off the process.  The rest is taken care of for you.
