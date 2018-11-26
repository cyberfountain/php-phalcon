FROM php:7.2.7-fpm-alpine3.7

ENV XDEBUG_STATUS true
ENV PHP_FPM_CONF "development"
ENV XDEBUG_REMOTE_HOST "192.168.0.5"
ENV XDEBUG_IDE_KEY "PHPSTORM"
ENV XDEBUG_PORT "7765"

ENV PHALCON_VERSION=3.4.0

RUN apk add --update --virtual build-dependencies \
        build-base \
        curl-dev \
        libzip-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libxml2-dev \
        gettext-dev \
        autoconf \
        file \
        g++ \
        gcc \
        make \
        pcre-dev \
        re2c \
    && pecl install xdebug-2.6.0 \
    && docker-php-ext-install -j$(nproc) mysqli pdo pdo_mysql zip gd gettext

RUN set -xe && \
    curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
    tar xzf v${PHALCON_VERSION}.tar.gz && cd cphalcon-${PHALCON_VERSION}/build && sh install && \
    echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini && \
    cd ../.. && rm -rf v${PHALCON_VERSION}.tar.gz cphalcon-${PHALCON_VERSION}

COPY conf/php.ini-$PHP_FPM_CONF /usr/local/etc/php/php.ini

COPY entrypoint/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN apk del build-dependencies

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]