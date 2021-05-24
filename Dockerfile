FROM codeforkjeff/passenger-ruby23:0.9.19-ruby-build
#FROM pennlib/passenger-ruby23:0.9.23-ruby-build

ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1

COPY oracle/instantclient-* /opt/oracle/
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN apt-get update && apt-get install -qq -y --no-install-recommends \
    libaio1 \
    shared-mime-info \
    unzip && \
    chmod +x /usr/local/bin/docker-entrypoint && \
    rm -f /etc/service/nginx/down /etc/nginx/sites-enabled/default && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/oracle/

RUN bash -c "ls *.zip | xargs -n1 unzip" && \
    ln -s /opt/oracle/instantclient_12_1/libclntsh.so.12.1 /opt/oracle/instantclient_12_1/libclntsh.so && \
    mkdir -p network/admin

COPY --chown=app:app . /tmp/app
COPY --chown=app:app Gemfile* /home/app/webapp/
COPY rails-env.conf /etc/nginx/main.d/rails-env.conf
COPY webapp.conf /etc/nginx/sites-enabled/webapp.conf

WORKDIR /home/app/webapp

# Install gems, add application files, and precompile assets
RUN gem install bundler && \
    bundle install && \
    mv /tmp/app/* .

# Clean up
RUN rm -fr /tmp/* /var/tmp/*

ENTRYPOINT ["docker-entrypoint"]

CMD ["/sbin/my_init"]
