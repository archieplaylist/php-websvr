FROM php:8.5-fpm-alpine

# Runtime libraries that must survive after the build deps are removed.
# (openssl, curl, libxml2, sqlite-libs, readline, zlib are already in the base image.)
RUN apk add --no-cache \
        bzip2 \
        freetype \
        gettext-libs \
        icu-libs \
        imagemagick \
        libjpeg-turbo \
        libldap \
        libmemcached-libs \
        libpng \
        libpq \
        libxslt \
        libzip \
        tzdata

RUN apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        bzip2-dev \
        freetype-dev \
        gettext-dev \
        icu-dev \
        imagemagick-dev \
        libjpeg-turbo-dev \
        libmemcached-dev \
        libpng-dev \
        libpq-dev \
        libxml2-dev \
        libxslt-dev \
        libzip-dev \
        linux-headers \
        openldap-dev \
        openssl-dev \
        zlib-dev \
    && docker-php-ext-install -j"$(nproc)" \
        bcmath bz2 calendar exif gettext mysqli pdo_mysql pdo_pgsql pgsql soap xsl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" gd intl ldap zip sockets \
    && pecl install xdebug && docker-php-ext-enable xdebug \
    && pecl install memcached && docker-php-ext-enable memcached \
    && pecl install mongodb  && docker-php-ext-enable mongodb \
    && pecl install redis    && docker-php-ext-enable redis \
    && yes '' | pecl install imagick && docker-php-ext-enable imagick \
    && apk del .build-deps \
    && rm -rf /tmp/* /var/tmp/* /usr/src/php
