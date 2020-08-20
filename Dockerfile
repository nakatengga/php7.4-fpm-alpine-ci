FROM php:7.4.3-fpm-alpine3.11

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
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev  \
    libxpm-dev \
    freetype-dev \
    zip \
    libzip \
    oniguruma-dev

RUN apk add --no-cache --virtual .persistent-deps \
    libpng \
    freetype \
    libjpeg-turbo \
    libsodium-dev \
    mysql-client \
    libzip-dev

RUN set -xe \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && docker-php-ext-configure mbstring --enable-mbstring \
    && docker-php-ext-configure gd \
    	--enable-gd \
        --with-freetype=/usr/include/ \
        --with-jpeg=/usr/include/ \
    && docker-php-ext-configure zip \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NPROC} \
        gd \
        pdo_mysql \
        mbstring \
        zip \
        pcntl \
        exif \
    && pecl install imagick \
	&& docker-php-ext-enable imagick
    && apk del .build-deps \
    && rm -rf /tmp/* \
    && rm -rf /var/www \
    && mkdir -p /var/www

COPY --from=composer:1.9.3 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www