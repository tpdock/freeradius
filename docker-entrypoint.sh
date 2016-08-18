#!/bin/bash
set -eo pipefail

# use rancher private IP if running in rancher
resp=$(curl http://rancher-metadata/2015-12-19/self/container/primary_ip) && PRIVATE_IP=$resp

####################################################################
###  Server Configuration                                        ###
####################################################################
if [ -z "$RADIUS_LISTEN_IP" ]; then
  export RADIUS_LISTEN_IP=${PRIVATE_IP:-127.0.0.1}
fi
envsubst '
          ${RADIUS_LISTEN_IP}
         ' < radiusd.conf.template > /etc/freeradius/radiusd.conf
####################################################################


####################################################################
###  Clients Configuration                                       ###
####################################################################
if [ -z "$RADIUS_CLIENT_IP" ]; then
  export RADIUS_CLIENT_IP=127.0.0.1
fi
if [ -z "$RADIUS_CLIENT_SECRET" ]; then
  export RADIUS_CLIENT_SECRET=testing123
fi

envsubst '
         ${RADIUS_CLIENT_IP}
         ${RADIUS_CLIENT_SECRET}
         ' < clients.conf.template > /etc/freeradius/clients.conf
####################################################################


####################################################################
###  Proxy Configuration                                         ###
####################################################################
if [ -n "$PROXY_DEFAULT_AUTH_HOST_PORT" ]; then
  export PROXY_DEFAULT_AUTH_HOST_PORT="authhost=$PROXY_DEFAULT_AUTH_HOST_PORT"
fi
if [ -n "$PROXY_DEFAULT_ACC_HOST_PORT" ]; then
  export PROXY_DEFAULT_ACC_HOST_PORT="acchost=$PROXY_DEFAULT_ACC_HOST_PORT"
fi
if [ -n "$PROXY_DEFAULT_SECRET" ]; then
  export PROXY_DEFAULT_SECRET="secret=$PROXY_DEFAULT_SECRET"
fi

envsubst '
         ${PROXY_DEFAULT_AUTH_HOST_PORT}
 	 ${PROXY_DEFAULT_ACC_HOST_PORT}
	 ${PROXY_DEFAULT_SECRET}
	 ' < proxy.conf.template > /etc/freeradius/proxy.conf
####################################################################


####################################################################
###    SQL Configuration                                         ###
####################################################################
if [ -z "$RADIUS_DB_HOST"]; then
  export RADIUS_DB_HOST=localhost
fi
if [ -z "$RADIUS_DB_PORT"]; then
  export RADIUS_DB_PORT=3306
fi
if [ -z "$RADIUS_DB_USERNAME"]; then
  export RADIUS_DB_USERNAME=radius
fi
if [ -z "$RADIUS_DB_PASSWORD"]; then
  export RADIUS_DB_PASSWORD=radpass
fi
if [ -z "$RADIUS_DB_NAME"]; then
  export RADIUS_DB_NAME=radius
fi

envsubst '
         ${RADIUS_DB_HOST}
         ${RADIUS_DB_PORT}
         ${RADIUS_DB_USERNAME}
         ${RADIUS_DB_PASSWORD}
         ${RADIUS_DB_NAME}
         ' < sql.conf.template > /etc/freeradius/sql.conf

if [ -z "$RADIUS_SQL"]; then
  export RADIUS_SQL=""
else
  export RADIUS_SQL=sql
fi

envsubst '
         $RADIUS_SQL
         ' < default.template > /etc/freeradius/sites-available/default
envsubst '
         $RADIUS_SQL
         ' < inner-tunnel.template > /etc/freeradius/sites-available/inner-tunnel

####################################################################

exec "$@"
