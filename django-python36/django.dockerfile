FROM ubuntu:16.04

LABEL maintainer="kamolcu@gmail.com"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -yqq && apt-get install -yqq software-properties-common wget > /dev/null
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:jonathonf/python-3.6
RUN apt-get update -yqq > /dev/null
RUN apt-get install -y supervisor build-essential python3.6 python3.6-dev python3-pip python3.6-venv
RUN apt-get dist-upgrade -yqq
RUN apt-get autoremove
RUN mkdir -p /var/log/supervisor
WORKDIR /tmp
RUN wget http://nginx.org/keys/nginx_signing.key
RUN apt-key add nginx_signing.key
RUN echo 'deb http://nginx.org/packages/mainline/ubuntu/ '$(lsb_release -cs)' nginx' > /etc/apt/sources.list.d/nginx.list
RUN apt-get update -yqq && apt-get install -yqq nginx
RUN apt-get install -yqq libmysqlclient-dev

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/main.conf /etc/nginx/conf.d/default.conf
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY conf/gunicorn.conf /etc/supervisor/conf.d/gunicorn.conf

ADD ./ /var/www
WORKDIR /var/www

RUN python3.6 -m pip install --upgrade pip
RUN python3.6 -m pip install -r /var/www/requirements.txt

ENV PYTHONUNBUFFERED 1

EXPOSE 80

CMD ["/usr/bin/supervisord"]
