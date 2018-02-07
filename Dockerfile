FROM ubuntu:16.04

RUN apt -y update; apt -y install software-properties-common;  \
    add-apt-repository -y ppa:freeradius/stable
RUN apt -y update; apt install -y freeradius=2.2.9-ppa1~xenial \
    freeradius-mysql freeradius-postgresql freeradius-utils    \
    mysql-client-core-5.7 curl gettext-base

EXPOSE 1812/udp 1813/udp

ADD templates/default.template default.template
ADD templates/inner-tunnel.template inner-tunnel.template
ADD templates/radiusd.conf.template radiusd.conf.template
ADD templates/proxy.conf.template proxy.conf.template
ADD templates/clients.conf.template clients.conf.template
ADD templates/sql.conf.template sql.conf.template
ADD templates/files.template files.template
ADD docker-entrypoint.sh docker-entrypoint.sh
ADD templates/eap.conf /etc/freeradius/eap.conf
ADD templates/dialup.conf /etc/freeradius/sql/mysql/dialup.conf
ADD templates/schema.sql /etc/freeradius/sql/mysql/schema.sql

ENTRYPOINT ["./docker-entrypoint.sh"]

CMD /usr/sbin/freeradius -X
