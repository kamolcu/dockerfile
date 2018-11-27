# dockerfile

Collection of dockerfiles

## PHP + Phalcon + Nginx

### Files

- Dockerfile: `phalcon-php72-fpm-nginx/phalcon.dockerfile`
- PHP-FPM Configuration: `phalcon-php72-fpm-nginx/conf/php-fpm.conf` is copied into the docker image at `/etc/php/7.2/fpm/`
  - `pm = dynamic`
  - `pm.start_servers = 5`
  - `pm.max_children = 1024`
- Nginx Configuration: `phalcon-php72-fpm-nginx/conf/nginx.conf` is copied into the docker image at `/etc/nginx/nginx.conf`.
  - `access_log off`
  - `server_tokens off`
  - `upstream fastcgi_backend` defines as `unix:/var/run/php/php7.2-fpm.sock`
- PHP INI: `phalcon-php72-fpm-nginx/conf/php.ini` is copied into the docker image at these locations:
  - `/etc/php/7.2/fpm/conf.d/`
  - `/etc/php/7.2/cli/conf.d/`

### Components Details

**Phalcon Version**: 3.4.1

**Phalcon Developer Tools Version**: 3.4.0

**Nginx Version**: 1.15.6

**Composer Version**: 1.7.3

**PHPUnit Version**: 6.5.13

**Default Timezone**: Asia/Bangkok

### How to use this image

```sh
 $ docker pull [your_namespace]/phalcon-php72-fpm-nginx
 ## Or use this project image
 $ docker pull kamolcu/phalcon-php72-fpm-nginx
```

### How to build the image

```sh
# Command Structure
$ cd [project_location]/dockerfile/phalcon-php72-fpm-nginx
$ docker build --no-cache -f phalcon.dockerfile -t [your_namespace]/phalcon-php72-fpm-nginx .
$ docker push [your_namespace]/phalcon-php72-fpm-nginx

# This project example:
$ cd /opt/src/dockerfile/phalcon-php72-fpm-nginx
$ docker build --no-cache -f phalcon.dockerfile -t kamolcu/phalcon-php72-fpm-nginx .
$ docker push kamolcu/phalcon-php72-fpm-nginx

```

### How to use this image as a command line

- Run composer command.

```sh
# Example: Th project directory is at /opt/src/project
# Assuming composer.json is at /opt/src/project
$ docker run --rm -v /opt/src/project:/opt/src/project \
-w /opt/src/project kamolcu/phalcon-php72-fpm-nginx \
php -d allow_url_fopen=on /usr/local/bin/composer update --optimize-autoloader

```

- Run PHPUnit command.

```sh
# Example: The project directory is at /opt/src/project
# Assuming phpunit.xml is at /opt/src/project
$ docker run --rm -v /opt/src/project:/opt/src/project \
-w /opt/src/project kamolcu/phalcon-php72-fpm-nginx \
phpunit --configuration phpunit.xml

```

### Nginx Configuration Notes

- `nginx.conf` defines `fastcgi_backend`

```
http {
    ...
    upstream fastcgi_backend {
        server unix:/var/run/php/php7.2-fpm.sock;
        keepalive 50;
    }
    ...
}
```

- `server` block refer to `fastcgi_backend` in `nginx.conf`.

```
server {
    ...
    location ~ \.php$ {
        try_files $uri =404;
        # 'fastcgi_backend' is defined in nginx.conf
        fastcgi_pass fastcgi_backend;
        fastcgi_index /index.php;
        include fastcgi_params;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        ...
    }
    ...
}
```

### PHP Modules

```sh
$ docker run --rm kamolcu/phalcon-php72-fpm-nginx php -m
[PHP Modules]
apcu
bcmath
bz2
calendar
Core
ctype
curl
date
dom
enchant
exif
fileinfo
filter
ftp
gd
gettext
gmp
hash
iconv
imap
intl
json
libxml
mbstring
mcrypt
memcached
mongodb
mysqli
mysqlnd
openssl
pcntl
pcre
PDO
pdo_dblib
pdo_mysql
pdo_pgsql
pdo_sqlite
pgsql
phalcon
Phar
posix
pspell
readline
redis
Reflection
session
shmop
SimpleXML
snmp
soap
sockets
sodium
SPL
sqlite3
standard
sysvmsg
sysvsem
sysvshm
tidy
tokenizer
wddx
xml
xmlreader
xmlrpc
xmlwriter
xsl
yaml
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
```

## PHP + Phalcon + Nginx + Xdebug

`phalcon-php72-fpm-nginx-xdebug` is almost the same as `phalcon-php72-fpm-nginx` except it includes [XDebug](https://xdebug.org/index.php) and also some configuration differences.

### Components Details

**Phalcon Version**: 3.4.1

**Phalcon Developer Tools Version**: 3.4.0

**Nginx Version**: 1.15.6

**Composer Version**: 1.7.3

**PHPUnit Version**: 6.5.13

**Xdebug Version**: 2.6.1

**Default Timezone**: Asia/Bangkok

### Nginx Configuration Notes

- `nginx.conf` defines timeout as 3600 seconds.

```
http {
    ...
    fastcgi_connect_timeout 3600s;
    fastcgi_send_timeout 3600s;
    fastcgi_read_timeout 3600s;
    ...
}
```

### PHP INI Notes

- `php.ini` defines execution timeout as 3600 seconds.

```
...
max_execution_time = 3600
default_socket_timeout = 3600
...
```

### Run PHPUnit with code coverage

```sh
# Example: The project directory is at /opt/src/project
# Assuming phpunit.xml is at /opt/src/project
$ docker run --rm -v /opt/src/project:/opt/src/project \
-w /opt/src/project kamolcu/phalcon-php72-fpm-nginx-xdebug \
phpunit --configuration phpunit.xml --coverage-html /opt/src/project/build/coverage
```
