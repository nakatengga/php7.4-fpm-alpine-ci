FROM php:7.3.13-fpm-alpine3.10

# persistent / runtime deps
ENV PHPIZE_DEPS \
    autoconf \
    cmake \
    file \
    g++ \
    gcc \
    libc-dev \
    pcre-dev \
    make \
    git \
    pkgconf \
    re2c \
    libzip \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev  \
    libxpm-dev \
    freetype-dev \
    zlib-dev \
    libzip-dev

RUN apk add --no-cache --virtual .persistent-deps \
    libpng \
    freetype \
    libjpeg-turbo \
    libsodium-dev \
    mysql-client

RUN set -xe \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && docker-php-ext-configure mbstring --enable-mbstring \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-configure gd --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NPROC} \
        gd \
        pdo_mysql \
        mbstring \
        zip \
        pcntl \
        exif \
    && apk del .build-deps \
    && rm -rf /tmp/* \
    && rm -rf /var/www \
    && mkdir -p /var/www

COPY --from=composer:1.9.1 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www