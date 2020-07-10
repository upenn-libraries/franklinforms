#!/bin/bash
set -e

if [ "$1" = "/sbin/my_init" ]; then
    if [ "$RAILS_ENV" = "development" ] && [ ! -z "$APP_UID" ] && [ ! -z "$APP_GID" ]; then
        usermod -u $APP_UID app
        groupmod -g $APP_GID app
    fi
fi

exec "$@"
