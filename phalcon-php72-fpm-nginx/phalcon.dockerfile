FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -yqq && apt-get install -yqq software-properties-common wget > /dev/null
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update -yqq > /dev/null
RUN apt-get dist-upgrade -yqq
RUN apt-get autoremove
WORKDIR /tmp
RUN wget http://nginx.org/keys/nginx_signing.key
RUN apt-key add nginx_signing.key
RUN echo 'deb http://nginx.org/packages/mainline/ubuntu/ '$(lsb_release -cs)' nginx' > /etc/apt/sources.list.d/nginx.list
RUN apt-get update -yqq && apt-get install -yqq nginx

RUN apt-get install -yqq git unzip php7.2 php7.2-common php7.2-cli php7.2-fpm php7.2-mysql php7.2-mongodb
RUN apt-get install -yqq php-pear php7.2-bcmath php7.2-bz2 php7.2-dev php7.2-enchant php7.2-zip php7.2-curl php7.2-gd php7.2-gmp php7.2-imap php7.2-intl php7.2-json php7.2-xml php7.2-mbstring php7.2-opcache php7.2-pgsql php7.2-phpdbg php7.2-pspell php7.2-readline php7.2-snmp php7.2-soap php7.2-sqlite3 php7.2-tidy php7.2-xmlrpc php7.2-xsl php7.2-sybase

ENV FPM_DIR=/etc/php/7.2/fpm/
ENV FPM_CONF_DIR=${FPM_DIR}conf.d/
ENV CLI_DIR=/etc/php/7.2/cli/
ENV CLI_CONF_DIR=${CLI_DIR}conf.d/

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/php-fpm.conf ${FPM_DIR}
COPY conf/php.ini ${FPM_DIR}
COPY conf/php.ini ${CLI_DIR}

# cphalcon, phalcon-devtools, composer
ENV PHALCON_VERSION=3.4.1
ENV PHALCON_DEVTOOLS_VERSION=3.4.0

WORKDIR /cphalcon
RUN wget https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz --output-document=./phalcon.tar.gz
RUN tar -xzf phalcon.tar.gz && cd cphalcon-${PHALCON_VERSION}/build && ./install
RUN echo 'extension=phalcon.so' | tee ${CLI_CONF_DIR}30-phalcon.ini
RUN echo 'extension=phalcon.so' | tee ${FPM_CONF_DIR}30-phalcon.ini
RUN rm -rf /cphalcon

WORKDIR /phalcon-devtools
RUN wget https://github.com/phalcon/phalcon-devtools/archive/v${PHALCON_DEVTOOLS_VERSION}.tar.gz --output-document=./phalcon.tar.gz
RUN tar -xzf phalcon.tar.gz && mv phalcon-devtools-${PHALCON_DEVTOOLS_VERSION} /usr/local/phalcon-devtools && ln -s /usr/local/phalcon-devtools/phalcon.php /usr/local/bin/phalcon && chmod ugo+x /usr/local/bin/phalcon

RUN php -d allow_url_fopen=on -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -d allow_url_fopen=on  composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

# PHP Extension
RUN apt-get install -y libmcrypt-dev

RUN pecl install mcrypt-1.0.1
RUN echo 'extension=mcrypt.so' | tee ${CLI_CONF_DIR}30-mcrypt.ini
RUN echo 'extension=mcrypt.so' | tee ${FPM_CONF_DIR}30-mcrypt.ini

RUN pecl install apcu_bc-1.0.4
RUN echo 'extension=apcu.so' | tee ${CLI_CONF_DIR}30-apcu.ini
RUN echo 'extension=apcu.so' | tee ${FPM_CONF_DIR}30-apcu.ini

RUN apt-get install -y libyaml-dev
RUN pecl install yaml
RUN echo 'extension=yaml.so' | tee ${CLI_CONF_DIR}30-yaml.ini
RUN echo 'extension=yaml.so' | tee ${FPM_CONF_DIR}30-yaml.ini

RUN pecl install redis
RUN echo 'extension=redis.so' | tee ${CLI_CONF_DIR}30-redis.ini
RUN echo 'extension=redis.so' | tee ${FPM_CONF_DIR}30-redis.ini

RUN apt-get install -y libmemcached-dev pkg-config zlib1g-dev
RUN pecl install memcached
RUN echo 'extension=memcached.so' | tee ${CLI_CONF_DIR}30-memcached.ini
RUN echo 'extension=memcached.so' | tee ${FPM_CONF_DIR}30-memcached.ini

RUN php -d allow_url_fopen=on /usr/local/bin/composer global require --dev phpunit/phpunit ^6
RUN ln -s ~/.composer/vendor/bin/phpunit /usr/local/bin/

# Timezone
RUN unlink /etc/localtime ; ln -s /usr/share/zoneinfo/Asia/Bangkok /etc/localtime

# Clean repository
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/server

EXPOSE 80

CMD service php7.2-fpm start && \
    nginx -g "daemon off;"
