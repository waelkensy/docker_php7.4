FROM php:7.4-apache

ENV COMPOSER_ALLOW_SUPERUSER=1

EXPOSE 80
WORKDIR /app

# git, unzip & zip are for composer
RUN apt-get update -qq && \
    apt-get install -qy \
    git \
    gnupg \
    iputils-ping \
    libicu-dev \
    unzip \
    libxslt-dev \
    libxml2-dev \
    libjpeg-dev \
    libzip-dev \
    libfreetype6-dev \
    zip && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# PHP Extensions
RUN docker-php-ext-install -j$(nproc) opcache pdo_mysql

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-jpeg --with-freetype=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN apt-get -y update \
&& apt-get install -y zlib1g-dev libicu-dev g++ \
&& docker-php-ext-configure intl \
&& docker-php-ext-install intl \
&& docker-php-ext-install soap \
&& docker-php-ext-install bcmath \
&& docker-php-ext-install sockets \
&& docker-php-ext-install zip \
&& docker-php-ext-install xsl

RUN apt-get install vim -y
RUN apt-get install cron -y

COPY conf/php.ini /usr/local/etc/php/conf.d/php.ini
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Apache
COPY conf/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY conf/apache.conf /etc/apache2/conf-available/z-app.conf

RUN a2enmod rewrite remoteip && \
    a2enconf z-app
