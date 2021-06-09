#!/bin/bash
set -e

if [ "$1" = "bin/rails" ]; then
    if [ ! -z "$APP_UID" ] && [ ! -z "$APP_GID" ]; then
        usermod -u $APP_UID app
        groupmod -g $APP_GID app
    fi

    if [ "$RAILS_ENV" = "development" ]; then
        bundle config --local path ${RAILS_ROOT}/vendor/bundle
        bundle config set --local with 'development:test:assets'
        bundle install -j$(nproc) --retry 3
    fi

    chown -R app:app .

    # run the application as the app user
    exec gosu app "$@"
fi

exec "$@"
