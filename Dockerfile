FROM codeforkjeff/passenger-ruby23:0.9.19-ruby-build

MAINTAINER Christopher Clement <clemenc@upenn.edu>

EXPOSE 80

ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1

RUN apt-get update && apt-get install -qq -y --no-install-recommends \
        libaio1 \
        unzip

RUN mkdir -p /opt/oracle

COPY oracle/instantclient-* /opt/oracle/

RUN mkdir -p /home/app/webapp

COPY . /home/app/webapp

WORKDIR /opt/oracle/

RUN bash -c "ls *.zip | xargs -n1 unzip"

WORKDIR /opt/oracle/instantclient_12_1

RUN ln -s libclntsh.so.12.1 libclntsh.so

RUN mkdir -p network/admin

WORKDIR /home/app/webapp

RUN chown -R app.app .

RUN bundle install

# Enable Nginx and Passenger
RUN rm -f /etc/service/nginx/down

RUN rm /etc/nginx/sites-enabled/default

ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf

ADD rails-env.conf /etc/nginx/main.d/rails-env.conf

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init"]
