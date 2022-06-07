FROM php:7.4.3-fpm-alpine

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_DISABLE_XDEBUG_WARN=1 \
    PHPREDIS_VERSION=5.1.1
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
    tzdata \
    $PHPIZE_DEPS \
    && apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted \
    && cp /usr/share/zoneinfo/UTC /etc/localtime \
    && echo 'UTC' > /etc/localtime \
    && apk add --no-cache \
    openssl-dev \
    bash \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    sqlite-dev \
    curl \
    curl-dev \
    libsodium-dev \
    icu-dev \
    libxml2-dev \
    recode-dev \
    libxslt-dev \
    git \
    openssh-client \
    libmcrypt-dev \
    libmcrypt \
    libzip-dev \
    libgcrypt-dev \
    oniguruma-dev \
    && apk --update --no-cache add grep \
    && mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ \
    && docker-php-ext-install -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1)\
    gd \
    bcmath \
    opcache \
    iconv \
    mysqli \
    pdo \
    pdo_mysql \
    pdo_sqlite \
    zip \
    xml \
    xsl \
    intl \
    json \
    mbstring \
    curl \
    simplexml \
    soap \
    redis \
    sockets \
    && apk del .build-deps \
    && rm -rf /tmp/* /var/cache/apk/*

# gmp
RUN apk add --update --no-cache gmp gmp-dev \
    && docker-php-ext-install gmp

# Ставим opcache https://laravel-news.com/php-opcache-docker
RUN docker-php-ext-install opcache
# RUN docker-php-ext-install pcntl

# composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN sed -ri 's/^www-data:x:82:82:/www-data:x:1000:1000:/' /etc/passwd
RUN sed -i '/^access.log/ s/^/;/' /usr/local/etc/php-fpm.d/docker.conf

WORKDIR /var/www
