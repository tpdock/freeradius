# FreeRADIUS
FreeRADIUS 2.2.8 server based on Ubuntu 16.04 with MYSQL support https://hub.docker.com/_/ubuntu/

Source: https://github.com/tpdock/freeradius

Available configuration environments:

| Environment Name              | Default Value   | Description                                                                             | Config File   |
|-------------------------------|-----------------|-----------------------------------------------------------------------------------------|-------------- |
| RADIUS_LISTEN_IP              | 127.0.0.1       | IP address on which to listen                                                           | radiusd.conf  |
| RADIUS_CLIENT_IP              | 127.0.0.1       | RADIUS client IP address                                                                | clients.conf  |
| RADIUS_CLIENT_SECRET          | testing123      | The shared secret used to "encrypt" and "sign" packets between the NAS and FreeRADIUS   | clients.conf  |
| RADIUS_CLIENTS                | no              | Option to define many radius clients in form secret1@ip1,secret2@ip2                    | clients.conf  |
| PROXY_DEFAULT_AUTH_HOST_PORT  | no              | The authentication proxy target configuration for DEFAULT realm in form host:port       | proxy.conf    |
| PROXY_DEFAULT_ACC_HOST_PORT   | no              | The accounting proxy target configuration for DEFAULT realm in form host:port           | proxy.conf    |
| PROXY_DEFAULT_SECRET          | no              | The shared secret                                                                       | proxy.conf    |
| RADIUS_SQL                    | no              | Enable SQL configuration. To enable SQL set it to `true`                                | default/inner-tunnel |
| RADIUS_DB_HOST                | localhost       | Database host                                                                           | sql.conf      |
| RADIUS_DB_PORT                | 3306            | Database port                                                                           | sql.conf      |
| RADIUS_DB_NAME                | radius          | Database name                                                                           | sql.conf      |
| RADIUS_DB_USERNAME            | radius          | Database login                                                                          | sql.conf      |
| RADIUS_DB_PASSWORD            | radpass         | Database password                                                                       | sql.conf      |


## To start the server using default configuration:

```
$ docker run -itd \
  --name freeradius \
  -e RADIUS_LISTEN_IP=* \
  -e RADIUS_CLIENTS=secret@127.0.0.1 \
  tpdock/freeradius
```



## To proxy all requests to some RADIUS home server:

```
$ docker run -itd \
  --name freeradius \
  -e RADIUS_LISTEN_IP=* \
  -e RADIUS_CLIENTS=secret@127.0.0.1 \
  -e ROXY_DEFAULT_AUTH_HOST_PORT=127.0.0.2:1812 \
  -e PROXY_DEFAULT_ACC_HOST_PORT=127.0.0.2:1813 \
  -e PROXY_DEFAULT_SECRET=secret \
  tpdock/freeradius
```


## To start FreeRADIUS with MYSQL

### Start and configure the MYSQL container `freeradiusdb` first:

```
$ docker run -itd \
--name=freeradiusdb \
-e MYSQL_ROOT_PASSWORD=root \
-e MYSQL_DATABASE=freeradius \
-e MYSQL_USER=freeradius \
-e MYSQL_PASSWORD=freeradius \
mysql:latest
```


### Start FreeRADIUS and link it to MYSQL:

```
$ docker run -itd \
--name freeradius \
--link freeradiusdb:mysql \
-e RADIUS_LISTEN_IP=* \
-e RADIUS_CLIENTS=secret@127.0.0.1 \
-e RADIUS_SQL=true \
-e RADIUS_DB_NAME=mysql \
-e RADIUS_DB_NAME=freeradius \
-e RADIUS_DB_USERNAME=freeradius \
-e RADIUS_DB_PASSWORD=freeradius \
tpdock/freeradius
```

### Prepare DB

```
docker exec -it freeradius mysql -ufreeradius -pfreeradius -hmysql -e "source /etc/freeradius/sql/mysql/schema.sql" freeradius
```

### Create some user `test` with password `test`:

```
docker exec -it freeradius mysql -ufreeradius -pfreeradius -hmysql -e "insert into radcheck (username, attribute, op, value) values ('test', 'Cleartext-Password', ':=', 'test');" freeradius
```

### Test it:

```
radtest test test 172.17.0.3 1812 secret
```
