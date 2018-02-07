FROM ubuntu:16.04

RUN apt -y update; apt install -y freeradius freeradius-mysql freeradius-postgresql freeradius-utils curl gettext-base vim mysql-client-core-5.7

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

ENTRYPOINT ["./docker-entrypoint.sh"]

CMD /usr/sbin/freeradius -X
