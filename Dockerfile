FROM php:7.1-apache
MAINTAINER "Ere Maijala <ere@labs.fi>"

ENV MYSQL_ROOT_PASSWORD=raparperi
ENV MYSQL_USER=mlinvoice
ENV MYSQL_PASSWORD=karviainen
ENV MYSQL_DATABASE=mlinvoice
ENV DATE_TIMEZONE=Europe/Helsinki
ENV MYSQL_BASEDIR=/var/lib/mysql

VOLUME /var/lib/mysql

WORKDIR /usr/local/mlinvoice
EXPOSE 80

RUN apt-get update && apt-get install -y --no-install-recommends \
        unzip \
        zlib1g-dev libcurl4-openssl-dev libmcrypt-dev libxslt1-dev libgd3 libpng-dev libjpeg-dev \
        mariadb-common mariadb-server mariadb-client \
        nano vim

RUN docker-php-ext-install -j"$(nproc)" xsl intl mysqli mcrypt zip gd && \
    a2enmod rewrite

COPY httpd_mlinvoice.conf.sample /etc/apache2/sites-available/000-default.conf
COPY docker-run.sh /usr/local
RUN chmod +x /usr/local/docker-run.sh

CMD ["/usr/local/docker-run.sh"]
