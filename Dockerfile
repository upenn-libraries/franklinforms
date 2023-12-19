FROM codeforkjeff/passenger-ruby23:0.9.19-ruby-build
#FROM pennlib/passenger-ruby23:0.9.23-ruby-build

ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1

COPY oracle/instantclient-* /opt/oracle/
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

# Replace Let's Encrypt's expired DST Root CA X3 cert, which expired on 2021.09.30, with the newer ISRG Root X1 cert
# https://letsencrypt.org/docs/certificate-compatibility/
ADD https://letsencrypt.org/certs/isrgrootx1.pem /tmp/isrgrootx1.pem
RUN rm /usr/share/ca-certificates/mozilla/DST_Root_CA_X3.crt && \
    mkdir /usr/local/share/ca-certificates/letsencrypt.com && \
    mv /tmp/isrgrootx1.pem /usr/local/share/ca-certificates/letsencrypt.com/isrgrootx1.crt && \
    sed -i 's~^mozilla/DST_Root_CA_X3.crt$~!mozilla/DST_Root_CA_X3.crt~g' /etc/ca-certificates.conf && \
    update-ca-certificates --fresh


RUN apt-get update && apt-get install -qq -y --no-install-recommends \
    libaio1 \
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
RUN gem install bundler -v "<2.3" && \
    bundle install && \
    mv /tmp/app/* .

# Clean up
RUN rm -fr /tmp/* /var/tmp/*

ENTRYPOINT ["docker-entrypoint"]

CMD ["/sbin/my_init"]
