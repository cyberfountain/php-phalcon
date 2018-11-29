FROM php:7.2.7-fpm-alpine3.7

ENV XDEBUG_STATUS true
ENV XDEBUG_REMOTE_HOST "192.168.0.5"
ENV XDEBUG_IDE_KEY "PHPSTORM"
ENV XDEBUG_PORT "7765"
ENV APPLICATION_ENV "development"

ENV DB_HOST "192.168.0.5"
ENV DB_USER "admin"
ENV DB_PASSWORD "admin"
ENV DB_DATABASE "db"

ARG PHALCON_VERSION=3.2.2

RUN apk add --update --virtual build-dependencies \
        build-base \
        curl-dev \
        libzip-dev \
	postgresql-dev \
        autoconf \
        file \
        g++ \
        gcc \
        make \
        pcre-dev \
        re2c \
    && pecl install xdebug-2.6.1 \
    && pecl install redis && docker-php-ext-enable redis \
    && docker-php-ext-install pdo pdo_pgsql zip

RUN set -xe && \
    curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
    tar xzf v${PHALCON_VERSION}.tar.gz && cd cphalcon-${PHALCON_VERSION}/build && sh install && \
    echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini && \
    cd ../.. && rm -rf v${PHALCON_VERSION}.tar.gz cphalcon-${PHALCON_VERSION}

# Memory Limit
RUN echo "memory_limit=2048M" > $PHP_INI_DIR/conf.d/memory-limit.ini
RUN echo "max_execution_time=900" >> $PHP_INI_DIR/conf.d/memory-limit.ini
RUN echo "post_max_size=20M" >> $PHP_INI_DIR/conf.d/memory-limit.ini
RUN echo "upload_max_filesize=20M" >> $PHP_INI_DIR/conf.d/memory-limit.ini

# Disable PathInfo
RUN echo "cgi.fix_pathinfo=0" > $PHP_INI_DIR/conf.d/path-info.ini

# Time Zone
RUN echo 'date.timezone="Europe/London"' > $PHP_INI_DIR/conf.d/date_timezone.ini

COPY entrypoint/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN apk del build-dependencies

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
