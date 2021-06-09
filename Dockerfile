# Global Build Args ----------------------------------
# Bundle home
ARG BUNDLE_HOME=vendor/bundle

# Ruby version
ARG RUBY_VERSION=2.7.3

# The root of our app
ARG RAILS_ROOT=/home/app

# Ruby build env
ARG RAILS_ENV=development

# Build Stage ----------------------------------------
FROM ruby:${RUBY_VERSION}-slim AS base

ARG BUILD_PACKAGES="build-essential freetds-dev libaio1"

ARG BUNDLE_HOME
ENV BUNDLE_HOME=${BUNDLE_HOME}

ARG RAILS_ROOT
ENV RAILS_ROOT=${RAILS_ROOT}

ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}

ENV BUNDLE_APP_CONFIG="${RAILS_ROOT}/.bundle"
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1

# Prepare oracle files
COPY oracle/instantclient-* /opt/oracle/

WORKDIR /opt/oracle/

RUN apt-get update && apt-get install -y unzip && \
    bash -c 'unzip -q "*.zip"' && \
    ln -s /opt/oracle/instantclient_12_1/libclntsh.so.12.1 /opt/oracle/instantclient_12_1/libclntsh.so && \
    mkdir -p network/admin && \
    rm -rf /var/lib/apt/lists/*

# Preprare rails specific files
WORKDIR ${RAILS_ROOT}

COPY Gemfile* ./

# Install build packages
RUN apt-get update && apt-get install -y ${BUILD_PACKAGES} && \
    bundle config path ${RAILS_ROOT}/${BUNDLE_HOME} && \
    set -eux; \
    if [ "${RAILS_ENV}" = "development" ]; then \
        bundle config set with "development:test:assets"; \
    else \
        bundle config set without "development:test:assets"; \
    fi && \
    bundle install -j$(nproc) --retry 3 && \
    rm -rf ${RAILS_ROOT}/${BUNDLE_HOME}/ruby/${RUBY_MAJOR}.0/cache/*.gem && \
    find ${RAILS_ROOT}/${BUNDLE_HOME}/ruby/${RUBY_MAJOR}.0/gems/ \( -name "*.c" -o -name "*.o" \) -delete && \
    rm -rf /var/lib/apt/lists/*

COPY . .


# Development Stage ----------------------------------
FROM ruby:${RUBY_VERSION}-slim as development

ARG BUNDLE_HOME
ENV BUNDLE_HOME=${BUNDLE_HOME}

ARG DEVELOPMENT_PACKAGES="build-essential freetds-dev libaio1"

ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}

ARG RAILS_ROOT
ENV RAILS_ROOT=${RAILS_ROOT}

# Set Rails env
ENV BUNDLE_APP_CONFIG="${RAILS_ROOT}/.bundle"
ENV EXECJS_RUNTIME=Disabled
ENV GEM_HOME="${RAILS_ROOT}/${BUNDLE_HOME}/ruby/${RUBY_MAJOR}.0/"
ENV GEM_PATH="${RAILS_ROOT}/${BUNDLE_HOME}/ruby/${RUBY_MAJOR}.0/"
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1
ENV NLS_LANG=$LANG
ENV PATH="${RAILS_ROOT}/${BUNDLE_HOME}/ruby/${RUBY_MAJOR}.0/bin:${PATH}"

# install gosu
RUN set -eux; \
    apt-get update; \
    apt-get install -y gosu; \
    rm -rf /var/lib/apt/lists/*; \
    # verify that the binary works
    gosu nobody true

RUN groupadd app && useradd -g app -m -d ${RAILS_ROOT} app

WORKDIR ${RAILS_ROOT}

COPY ./docker-entrypoint.sh /usr/local/bin/
COPY --from=base ${RAILS_ROOT} ${RAILS_ROOT}
COPY --from=base /opt/oracle/ /opt/oracle/

RUN apt-get update && apt-get install -y ${DEVELOPMENT_PACKAGES} && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    find . -type d -exec chmod 755 {} + && \
    find . -type f -exec chmod 644 {} + && \
    find bin -type f -exec chmod 744 {} + && \
    chmod +x -R ${RAILS_ROOT}/${BUNDLE_HOME}/ruby/${RUBY_MAJOR}.0/bin/ && \
    chown -R app:app . && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3000
VOLUME ${RAILS_ROOT}

CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]


# Production Stage -----------------------------------
FROM ruby:${RUBY_VERSION}-slim as production

ARG BUNDLE_HOME
ENV BUNDLE_HOME=${BUNDLE_HOME}

ARG PRODUCTION_PACKAGES="freetds-dev libaio1 nodejs"

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

ARG RAILS_ROOT
ENV RAILS_ROOT=${RAILS_ROOT}

# Set Rails env
ENV BUNDLE_APP_CONFIG="${RAILS_ROOT}/.bundle"
ENV GEM_HOME="${RAILS_ROOT}/${BUNDLE_HOME}/ruby/${RUBY_MAJOR}.0/"
ENV GEM_PATH="${RAILS_ROOT}/${BUNDLE_HOME}/ruby/${RUBY_MAJOR}.0/"
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1
ENV NLS_LANG=$LANG
ENV PATH="${RAILS_ROOT}/${BUNDLE_HOME}/ruby/${RUBY_MAJOR}.0/bin:${PATH}"
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

# install gosu
RUN set -eux; \
    apt-get update; \
    apt-get install -y gosu; \
    rm -rf /var/lib/apt/lists/*; \
    # verify that the binary works
    gosu nobody true

RUN groupadd app && useradd -g app -m -d ${RAILS_ROOT} app

WORKDIR ${RAILS_ROOT}

COPY ./docker-entrypoint.sh /usr/local/bin/
COPY --from=base ${RAILS_ROOT} ${RAILS_ROOT}
COPY --from=base /opt/oracle/ /opt/oracle/

RUN apt-get update && apt-get install -y ${PRODUCTION_PACKAGES} && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    rails assets:precompile && \
    find . -type d -exec chmod 755 {} + && \
    find . -type f -exec chmod 644 {} + && \
    find bin -type f -exec chmod 744 {} + && \
    chmod +x -R ${RAILS_ROOT}/${BUNDLE_HOME}/ruby/${RUBY_MAJOR}.0/bin/ && \
    chown -R app:app . && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3000
VOLUME ${RAILS_ROOT}

CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
